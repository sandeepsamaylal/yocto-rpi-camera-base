#include <gst/gst.h>
#include <gst/rtsp-server/rtsp-server.h>

#include <stdlib.h>
#include <string.h>

static int env_int(const char *name, int fallback) {
    const char *v = getenv(name);
    if (v == NULL || *v == '\0') {
        return fallback;
    }
    return atoi(v);
}

static const char *env_str(const char *name, const char *fallback) {
    const char *v = getenv(name);
    if (v == NULL || *v == '\0') {
        return fallback;
    }
    return v;
}

int main(int argc, char *argv[]) {
    GMainLoop *loop;
    GstRTSPServer *server;
    GstRTSPMountPoints *mounts;
    GstRTSPMediaFactory *factory;
    gchar *pipeline;

    const int udp_port = env_int("RTSP_UDP_PORT", 5600);
    const int rtsp_port = env_int("RTSP_PORT", 8554);
    const int framerate = env_int("RTSP_FRAMERATE", 30);
    const char *mount_path = env_str("RTSP_MOUNT", "/camera");

    gst_init(&argc, &argv);

    loop = g_main_loop_new(NULL, FALSE);
    server = gst_rtsp_server_new();
    mounts = gst_rtsp_server_get_mount_points(server);
    factory = gst_rtsp_media_factory_new();

    pipeline = g_strdup_printf(
        "( udpsrc port=%d caps=\"video/x-h264,stream-format=(string)byte-stream,alignment=(string)au,framerate=(fraction)%d/1\" "
        "! h264parse config-interval=-1 ! rtph264pay name=pay0 pt=96 )",
        udp_port,
        framerate);

    gst_rtsp_media_factory_set_launch(factory, pipeline);
    gst_rtsp_media_factory_set_shared(factory, TRUE);
    gst_rtsp_media_factory_set_protocols(factory, GST_RTSP_LOWER_TRANS_TCP);
    gst_rtsp_mount_points_add_factory(mounts, mount_path, factory);

    g_object_unref(mounts);

    gchar *service = g_strdup_printf("%d", rtsp_port);
    gst_rtsp_server_set_service(server, service);
    g_free(service);

    gst_rtsp_server_attach(server, NULL);

    g_print("RTSP relay ready (TCP): rtsp://0.0.0.0:%d%s (source udp://127.0.0.1:%d)\n",
            rtsp_port,
            mount_path,
            udp_port);

    g_free(pipeline);
    g_main_loop_run(loop);

    g_main_loop_unref(loop);
    g_object_unref(server);
    return 0;
}
