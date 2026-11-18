{ inputs, ... }:
{
  default = final: prev: {
    # fnott segfaults in wl_pointer_motion when hovering a notification
    # whose output was cleared by surface_leave() (multi-monitor, mixed scale).
    fnott = prev.fnott.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ./patches/fnott-pointer-motion-null-monitor.patch ];
    });
  };
}
