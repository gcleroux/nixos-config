{ pkgs, config, ... }:
let
  kubectl = rec {
    source = ./kubectl_aliases;
    target = "fish/kubectl_aliases";
    path = "${config.xdg.configHome}/${target}";
  };
in
{
  # Load the kubectl_aliases in $XDG_CONFIG_HOME
  xdg.configFile.kubectl_aliases = {
    inherit (kubectl) source target;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      # Load the KUBECONFIG variable, keeping the per-shell context layers inherited from a parent shell
      set -gx KUBECONFIG (
        begin
          string split : -- "$KUBECONFIG" | string match '*/kube-session-*.yaml'
          ${pkgs.busybox}/bin/find "${config.home.homeDirectory}/.kube/Configs" \
            -type f \
            -name '*.yaml' \
          | ${pkgs.busybox}/bin/sort
        end \
        | string join :
      )
    '';
    interactiveShellInit = ''
      # Disable greeting
      set fish_greeting

      # Per-shell kubeconfig layer in front of KUBECONFIG: kubectl writes the current-context there,
      # so kcx/kns only affect this shell and never modify the cluster files
      set -g __kube_session $XDG_RUNTIME_DIR/kube-session-$fish_pid.yaml
      touch $__kube_session
      set -gx KUBECONFIG $__kube_session:$KUBECONFIG
      function __kube_session_cleanup --on-event fish_exit
        rm -f $__kube_session
      end
      complete -c kcx -f -a '(kubectl config get-contexts -o name)'
      complete -c kns -f -a '(kubectl get namespaces -o name | string replace namespace/ "")'

      # Load the kubectl_aliases file
      source (cat ${kubectl.path} | sed -r 's/(kubectl.*) --watch/watch \1/g' | psub)
    '';
    functions = {
      kcx = {
        description = "Switch kube context for this shell only";
        body = ''
          set -l ctx $argv[1]
          test -n "$ctx"; or set ctx (kubectl config get-contexts -o name | fzf --height 40%); or return
          kubectl config use-context $ctx
        '';
      };
      kns = {
        description = "Switch kube namespace for this shell only";
        body = ''
          set -l ctx (kubectl config current-context); or return
          set -l ns $argv[1]
          test -n "$ns"; or set ns (kubectl get namespaces -o name | string replace namespace/ "" | fzf --height 40%); or return
          # Override the context in the session layer so the namespace doesn't land in the cluster file
          set -l cluster (kubectl config view -o jsonpath="{.contexts[?(@.name=='$ctx')].context.cluster}")
          set -l user (kubectl config view -o jsonpath="{.contexts[?(@.name=='$ctx')].context.user}")
          kubectl config set-context $ctx --cluster=$cluster --user=$user --namespace=$ns \
            --kubeconfig=$__kube_session >/dev/null
          and echo "Namespace $ns on $ctx (this shell only)"
        '';
      };
    };
    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

      # Bat aliases
      bat = "bat -p";
      ban = "batman";
      biff = "batdiff";
      brep = "batgrep";

      f = "yazi";
      v = "nvim";

      nnn = "nnn -deo";

      gc = "git clone";
      gs = "git status";

      nixconf = "cd /etc/nixos";
      ns = "nix-shell -p";
      search = "nix search nixpkgs";
    };
  };
}
