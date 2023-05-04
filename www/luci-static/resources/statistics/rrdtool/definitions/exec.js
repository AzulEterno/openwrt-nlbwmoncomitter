'use strict';

return L.Class.extend({
    title: _('Exec'),

    rrdargs: function (graph, host, plugin, plugin_instance, dtype) {
        if (plugin_instance == 'fan_device_0') {
            return {
                title: "Fan Device 0 RPM",
                vlabel: "RPM",
                data: {
                    types: ["count"],
                    options: {
                        count: {
                            title: "RPM"
                        },
                    }
                }
            };
        }
    }
});