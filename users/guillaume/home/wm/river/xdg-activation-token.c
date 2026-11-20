// Print an xdg-activation token for the program started next (XDG_ACTIVATION_TOKEN).
// The token isn't tied to a seat: wlroots only checks a seat serial and the focused
// surface when a client sets them. River answers an activation request from an unfocused
// window by marking it urgent. Tokens expire after 30 seconds.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wayland-client.h>

#include "xdg-activation-v1.h"

static struct xdg_activation_v1 *activation;
static char *token;

static void registry_global(void *data, struct wl_registry *registry, uint32_t name,
                            const char *interface, uint32_t version) {
    (void)data;
    (void)version;
    if (strcmp(interface, xdg_activation_v1_interface.name) == 0) {
        activation = wl_registry_bind(registry, name, &xdg_activation_v1_interface, 1);
    }
}

static void registry_global_remove(void *data, struct wl_registry *registry, uint32_t name) {
    (void)data;
    (void)registry;
    (void)name;
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_global,
    .global_remove = registry_global_remove,
};

static void token_done(void *data, struct xdg_activation_token_v1 *request, const char *value) {
    (void)data;
    (void)request;
    token = strdup(value);
}

static const struct xdg_activation_token_v1_listener token_listener = {
    .done = token_done,
};

int main(void) {
    struct wl_display *display = wl_display_connect(NULL);
    if (display == NULL) {
        fprintf(stderr, "xdg-activation-token: can't connect to the Wayland display\n");
        return 1;
    }

    struct wl_registry *registry = wl_display_get_registry(display);
    wl_registry_add_listener(registry, &registry_listener, NULL);
    wl_display_roundtrip(display);
    if (activation == NULL) {
        fprintf(stderr, "xdg-activation-token: the compositor has no xdg-activation-v1\n");
        return 1;
    }

    struct xdg_activation_token_v1 *request = xdg_activation_v1_get_activation_token(activation);
    xdg_activation_token_v1_add_listener(request, &token_listener, NULL);
    xdg_activation_token_v1_commit(request);
    while (token == NULL && wl_display_dispatch(display) != -1) {
    }
    if (token == NULL) {
        return 1;
    }

    puts(token);
    return 0;
}
