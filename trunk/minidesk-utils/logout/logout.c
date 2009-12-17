#include <config.h>
#include <gtk/gtk.h>
#include <glib/gi18n.h>
#include <signal.h>
#include <gdk/gdk.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#ifdef HAVE_HAL
#include <dbus/dbus.h>
#endif

typedef enum {
        LOGOUT_ACTION_NONE     = 1 << 0,
        LOGOUT_ACTION_SHUTDOWN = 1 << 1,
        LOGOUT_ACTION_REBOOT   = 1 << 2,
        LOGOUT_ACTION_SUSPEND  = 1 << 3,
        LOGOUT_ACTION_HIBERNATE = 1 << 4,    /* HAL only */
}LogoutAction;

static gboolean on_expose( GtkWidget* w, GdkEventExpose* evt, GdkPixbuf* shot )
{
    if( GTK_WIDGET_REALIZED(w) && GDK_IS_DRAWABLE(w->window) )
    {
        gdk_draw_pixbuf( w->window, w->style->black_gc, shot,
                                    evt->area.x, evt->area.y,
                                    evt->area.x, evt->area.y,
                                    evt->area.width, evt->area.height,
                                    GDK_RGB_DITHER_NORMAL, 0, 0 );
    }
    return TRUE;
}

static GtkWidget* create_background()
{
    GtkWidget *back = NULL, *img;
    GdkPixbuf *tmp, *shot;
    GdkScreen *screen;

#if 0
    screen = gdk_screen_get_default();

    tmp = gdk_pixbuf_get_from_drawable( NULL,
                                        gdk_get_default_root_window(),
                                        NULL,
                                        0, 0, 0, 0,
                                        gdk_screen_get_width(screen),
                                        gdk_screen_get_height(screen) );

    shot = gdk_pixbuf_composite_color_simple( tmp,
                                              gdk_screen_get_width(screen),
                                              gdk_screen_get_height(screen),
                                              GDK_INTERP_NEAREST,
                          128, gdk_screen_get_width(screen),
                          0x000000, 0x000000);
    g_object_unref( tmp );

    back = gtk_window_new( GTK_WINDOW_TOPLEVEL );
    gtk_widget_set_app_paintable( back, TRUE );
    gtk_widget_set_double_buffered( back, FALSE );
    g_signal_connect( back, "expose-event", G_CALLBACK(on_expose), shot);
    g_object_weak_ref( back, (GWeakNotify)g_object_unref,  shot );

    gtk_window_fullscreen( back );
    gtk_window_set_decorated( back, FALSE );
    gtk_window_set_keep_above( (GtkWindow*)back, TRUE );
    gtk_widget_show_all( back );
#else
    back = gtk_window_new( GTK_WINDOW_TOPLEVEL );
    //gtk_widget_set_app_paintable( back, TRUE );
    gtk_window_set_decorated( back, FALSE );
    //gtk_window_set_keep_above( (GtkWindow*)back, TRUE );
    //gtk_widget_show_all( back );
#endif
    return back;
}

static void btn_clicked( GtkWidget* btn, gpointer id )
{
    GtkWidget* dlg = gtk_widget_get_toplevel( btn );
    gtk_dialog_response( GTK_DIALOG(dlg), GPOINTER_TO_INT(id) );
}

static GtkWidget* create_dlg_btn(const char* label, const char* icon, int response )
{
    GtkWidget* btn = gtk_button_new_with_mnemonic( label );
    gtk_button_set_alignment( (GtkButton*)btn, 0.0, 0.5 );
    g_signal_connect( btn, "clicked", G_CALLBACK(btn_clicked), GINT_TO_POINTER(response) );
    if( icon )
    {
        GtkWidget* img = gtk_image_new_from_icon_name( icon, GTK_ICON_SIZE_BUTTON );
        gtk_button_set_image( btn, img );
    }
    return btn;
}

/*
 *  These functions with the prefix "xfsm_" are taken from
 *  xfsm-shutdown-helper.c of xfce4-session with some modification.
 *  Copyright (c) 2003-2006 Benedikt Meurer <benny@xfce.org>
 */
static gboolean xfsm_shutdown_helper_hal_send ( LogoutAction action )
{
#ifdef HAVE_HAL
    DBusConnection *connection;
    DBusMessage        *message;
    DBusMessage        *result;
    DBusError             error;
    const char* method;
    dbus_int32_t suspend_arg = 0;

    /* The spec:
     http://people.freedesktop.org/~david/hal-spec/hal-spec.html#interface-device-systempower */
    switch( action )
    {
    case LOGOUT_ACTION_SHUTDOWN:
        method = "Shutdown";
        break;
    case LOGOUT_ACTION_REBOOT:
        method = "Reboot";
        break;
    case LOGOUT_ACTION_SUSPEND:
        method = "Suspend";
        break;
    case LOGOUT_ACTION_HIBERNATE:
        method = "Hibernate";
        break;
    default:
        return FALSE;    /* It's impossible to reach here, or it's a bug. */
    }

    /* initialize the error */
    dbus_error_init (&error);

    /* connect to the system message bus */
    connection = dbus_bus_get (DBUS_BUS_SYSTEM, &error);
    if (G_UNLIKELY (connection == NULL))
    {
        g_warning (G_STRLOC ": Failed to connect to the system message bus: %s", error.message);
        dbus_error_free (&error);
        return FALSE;
    }

    /* send the appropriate message to HAL, telling it to shutdown or reboot the system */
    message = dbus_message_new_method_call ("org.freedesktop.Hal",
                                                                                    "/org/freedesktop/Hal/devices/computer",
                                                                                    "org.freedesktop.Hal.Device.SystemPowerManagement",
                                                                                    method );
    if( action == LOGOUT_ACTION_SUSPEND )
        dbus_message_append_args( message, DBUS_TYPE_INT32, &suspend_arg, DBUS_TYPE_INVALID );

    result = dbus_connection_send_with_reply_and_block (connection, message, 2000, &error);
    dbus_message_unref (message);

    /* check if we received a result */
    if (G_UNLIKELY (result == NULL))
    {
        g_warning (G_STRLOC ": Failed to contact HAL: %s", error.message);
        dbus_error_free (&error);
        return FALSE;
    }

    /* pretend that we succeed */
    dbus_message_unref (result);
    return TRUE;
#else
    return FALSE;
#endif
}

int main( int argc, char** argv )
{
    GtkWidget *back = NULL, *dlg, *check, *btn, *label, *box = NULL, *vbox;
    int res;
    const char* p;
    char* file;
    GPid pid;
    GOptionContext *context;
    GError* err = NULL;

#ifdef ENABLE_NLS
    bindtextdomain ( GETTEXT_PACKAGE, PACKAGE_LOCALE_DIR );
    bind_textdomain_codeset ( GETTEXT_PACKAGE, "UTF-8" );
    textdomain ( GETTEXT_PACKAGE );
#endif

    gtk_init (&argc, &argv);

    back = create_background();

    gtk_icon_theme_append_search_path( gtk_icon_theme_get_default(),
                                            PACKAGE_DATA_DIR "/pixmaps/minilogout" );

    dlg = gtk_dialog_new_with_buttons( _("Logout"), (GtkWindow*)back, GTK_DIALOG_MODAL,
                                               GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL, NULL );
    gtk_container_set_border_width( (GtkContainer*)dlg, 6 );
    vbox = ((GtkDialog*)dlg)->vbox;

    label = gtk_label_new("");

    const char* session_name = g_getenv("DESKTOP_SESSION");
    if( ! session_name )
        session_name = "";
    /* %s is the name of the desktop session */
    gchar *prompt = g_strdup_printf( _("<b><big>Logout %s session?</big></b>"), session_name );

    gtk_label_set_markup( label, prompt );
    gtk_box_pack_start( vbox, label, FALSE, FALSE, 4 );

//    check_available_actions();
    int available_actions = LOGOUT_ACTION_SHUTDOWN | LOGOUT_ACTION_REBOOT | LOGOUT_ACTION_SUSPEND;

    if( available_actions & LOGOUT_ACTION_SHUTDOWN )
    {
        btn = create_dlg_btn(_("Sh_utdown"), "gnome-session-halt", LOGOUT_ACTION_SHUTDOWN );
        gtk_box_pack_start( vbox, btn, FALSE, FALSE, 4 );
    }
    if( available_actions & LOGOUT_ACTION_REBOOT )
    {
        btn = create_dlg_btn(_("_Reboot"), "gnome-session-reboot", LOGOUT_ACTION_REBOOT );
        gtk_box_pack_start( vbox, btn, FALSE, FALSE, 4 );
    }
    if( available_actions & LOGOUT_ACTION_SUSPEND )
    {
        btn = create_dlg_btn(_("_Suspend"), "gnome-session-suspend", LOGOUT_ACTION_SUSPEND );
        gtk_box_pack_start( vbox, btn, FALSE, FALSE, 4 );
    }
    if( available_actions & LOGOUT_ACTION_HIBERNATE )
    {
        btn = create_dlg_btn(_("_Hibernate"), "gnome-session-hibernate", LOGOUT_ACTION_HIBERNATE );
        gtk_box_pack_start( vbox, btn, FALSE, FALSE, 4 );
    }

    btn = create_dlg_btn(_("_Logout"), "gnome-session-logout", GTK_RESPONSE_OK );
    gtk_box_pack_start( vbox, btn, FALSE, FALSE, 4 );

    gtk_window_set_position( GTK_WINDOW(dlg), GTK_WIN_POS_CENTER_ALWAYS );
    gtk_window_set_decorated( (GtkWindow*)dlg, FALSE );
    gtk_widget_show_all( dlg );

    gtk_window_set_keep_above( (GtkWindow*)dlg, TRUE );

    gdk_pointer_grab( dlg->window, TRUE, 0, NULL, NULL, GDK_CURRENT_TIME );
    gdk_keyboard_grab( dlg->window, TRUE, GDK_CURRENT_TIME );

    switch( (res = gtk_dialog_run( (GtkDialog*)dlg )) )
    {
        case LOGOUT_ACTION_SHUTDOWN:
        case LOGOUT_ACTION_REBOOT:
        case LOGOUT_ACTION_SUSPEND:
        case LOGOUT_ACTION_HIBERNATE:
        case GTK_RESPONSE_OK:
            break;
        default:
            gtk_widget_destroy( dlg );
            gtk_widget_destroy( back );
            gdk_pointer_ungrab( GDK_CURRENT_TIME );
            gdk_keyboard_ungrab( GDK_CURRENT_TIME );
            return 0;
    }

    gdk_pointer_ungrab( GDK_CURRENT_TIME );
    gdk_keyboard_ungrab( GDK_CURRENT_TIME );

    gtk_widget_destroy( dlg );
    gtk_widget_destroy( back );

    xfsm_shutdown_helper_hal_send( res );

    return 0;
}
