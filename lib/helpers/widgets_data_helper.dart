class WidgetDataHelper {
  // Singleton instance
  static final WidgetDataHelper _instance = WidgetDataHelper._internal();

  factory WidgetDataHelper() {
    return _instance;
  }

  WidgetDataHelper._internal();

  // Data storage as a Map
  final Map<String, Map<String, dynamic>> _data = {
    "screen_header": {
      "type": "screen_header",
      "meta_info": [],
      "section_container": {"content": [], "context": []}
    },
    "screen_body": {
      "type": "screen_body",
      "meta_info": [],
      "section_container": {"content": [], "context": []}
    },
    "screen_footer": {
      "type": "screen_footer",
      "meta_info": [],
      "section_container": {"content": [], "context": []}
    },
    "section_container": {
      "type": "section_container",
      "slug": "",
      "sections": {"content": [], "context": []},
      "info_type": "",
      "meta_info": [],
      "content_type": "dynamic",
      "dynamic_action_type": "",
      "dynamic_onload_data_action": -1
    },
    "sections": {
      "type": "sections",
      "meta_info": [],
      "section_child": {"content": [], "context": []},
    },
    'info_text': {
      "hint": "",
      "slug": "",
      "type": "info_text",
      "label": "Scan SKUs and Container to proceed to next SKU",
      "style": "",
      "value": "",
      "action_id": -1,
      "meta_info": []
    },
    'plain_text': {
      "hint": "",
      "slug": "",
      "type": "plain_text",
      "label": "Please scan the bin location to start the counting process",
      "style": "",
      "value": "",
      "action_id": -1,
      "meta_info": []
    },
    'space_view': {
      "hint": "",
      "slug": "space_view",
      "type": "space_view",
      "label": "",
      "value": "",
      "action_id": -1,
      "meta_info": []
    },
  };

  // Get data by widget name
  Map<String, dynamic>? getData(String key) {
    return _data[key];
  }

  // Get all widget names
  List<String> getKeys() {
    return _data.keys.toList();
  }
}
