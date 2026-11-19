{ pkgs, ... }:
let
  # Upstream's aliases, with `kubectl ... --watch` turned into `watch kubectl ...`
  kubectlAliases = pkgs.runCommand "kubectl_aliases.fish" { } ''
    sed -r 's/(kubectl.*) --watch/watch \1/g' ${./kubectl_aliases} > $out
  '';
in
{
  programs.fish = {
    shellInit = ''
      # Load the KUBECONFIG variable, keeping the per-shell context layers inherited from a parent shell
      set -l configs $HOME/.kube/Configs/**.yaml
      set -gx KUBECONFIG (string join : -- (string split : -- "$KUBECONFIG" | string match '*/kube-session-*.yaml') $configs)
    '';
    interactiveShellInit = ''
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

      source ${kubectlAliases}
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
  };
}
