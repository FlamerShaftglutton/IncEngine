void export_to_xml(String _filename)
{
  XML root = new XML("game");
  
  export_resources_to_xml(root);
  export_buttons_to_xml(root);
  export_workers_to_xml(root);
  export_settings_to_xml(root);
  
  saveXML(root, _filename);
}

void export_resources_to_xml(XML root)
{
  XML rs = root.addChild("resources");
  
  for (int i = 0; i < resources.length; i++)
  {
    XML r = rs.addChild("resource");
    
    r.setContent(resources[i].singular_name + "," + resources[i].plural_name);
    r.setInt("value",resources[i].value);
    r.setInt("min",resources[i].min_to_display);
  }
}

void export_buttons_to_xml(XML root)
{
  XML bs = root.addChild("buttons");
  
  for (int i = 0; i < buttons.length; i++)
  {
    XML b = bs.addChild("button");
    
    b.addChild("title").setContent(buttons[i].get_string());
    b.addChild("tooltip").setContent(buttons[i].tooltip);
    
    b.setFloat("x", buttons[i].x);
    b.setFloat("y", buttons[i].y);
    b.setFloat("width", buttons[i].w);
    b.setFloat("height", buttons[i].h);
    b.setFloat("text_height", buttons[i].text_height / settings.default_text_size);
    b.setString("visible", buttons[i].visible ? "true" : "false");
    b.setString("enabled", buttons[i].enabled ? "true" : "false");
    if (buttons[i].autoclick)
      b.setString("autoclick","true");
    
    
    
    if (buttons[i].cooldown != null)
    {
      XML c = b.addChild("cooldown");
      
      c.addChild("current_amount").setFloatContent(buttons[i].cooldown.current_amount);
      c.addChild("worker_amount").setFloatContent(buttons[i].cooldown.current_worker_amount);
      c.addChild("max_amount").setFloatContent(buttons[i].cooldown.max_amount);
      c.addChild("display").setContent(buttons[i].cooldown.display ? "true" : "false");
    }
    
    if (buttons[i].hideuntil != null)
      b.addChild("hideuntil").setContent(buttons[i].hideuntil.list.to_string());
    
    if (buttons[i].hideafter != null)
      b.addChild("hideafter").setContent(buttons[i].hideafter.list.to_string());
    
    if (buttons[i].converter != null)
    {
      XML c = b.addChild("converter");
      
      if (buttons[i].converter.click != null)
        c.addChild("click").setContent(buttons[i].converter.click.to_string());
      
      if (buttons[i].converter.reset != null)
        c.addChild("reset").setContent(buttons[i].converter.reset.to_string());
    }
    
    if (buttons[i].myworkers != null && buttons[i].myworkers.size() > 0)
      b.addChild("workers").setContent(join(nf(buttons[i].myworkers.array(), 0), ","));
  }
}

void export_workers_to_xml(XML root)
{
  if (workers.size() > 0)
  {
    XML ws = root.addChild("workers");
    
    for (int i = 0; i < workers.size(); i++)
    {
      XML w = ws.addChild("worker");
      
      w.addChild("index").setIntContent(i);
      w.addChild("x").setFloatContent(workers.get(i).x);
      w.addChild("y").setFloatContent(workers.get(i).y);
      w.addChild("width").setFloatContent(workers.get(i).w);
      w.addChild("height").setFloatContent(workers.get(i).h);
      w.addChild("active").setContent(workers.get(i).active ? "true" : "false");
      if (workers.get(i).click_paid != null)
        w.addChild("click_paid").setContent(workers.get(i).click_paid.to_string());
    }
  }
}

void export_settings_to_xml(XML root)
{
  XML s = root.addChild("settings");
  
  s.addChild("default_text_size").setFloatContent(settings.default_text_size);
  s.addChild("default_text_color").setContent(color_to_string(settings.default_text_color));
  s.addChild("default_button_text_color").setContent(color_to_string(settings.default_button_text_color));
  s.addChild("default_button_color").setContent(color_to_string(settings.default_button_color));
  s.addChild("default_button_outline_color").setContent(color_to_string(settings.default_button_outline_color));
  s.addChild("default_disabled_text_color").setContent(color_to_string(settings.default_disabled_text_color));
  s.addChild("default_cooldown_overlay_color").setContent(color_to_string(settings.default_cooldown_overlay_color));
  s.addChild("default_cooldown_worker_overlay_color").setContent(color_to_string(settings.default_cooldown_worker_overlay_color));
  s.addChild("background_color").setContent(color_to_string(settings.background_color));
  s.addChild("worker_sprite_path").setContent(settings.worker_sprite_path);
  s.addChild("debugging").setContent(settings.debugging ? "true" : "false");
  s.addChild("time_multiplier").setFloatContent(settings.time_multiplier);
  s.addChild("window_width").setFloatContent(settings.window_width);
  s.addChild("window_height").setFloatContent(settings.window_height);
  s.addChild("mq_width").setFloatContent(settings.mq_width);
  s.addChild("mq_text_size").setFloatContent(settings.mq_text_size);
  s.addChild("mq_lifetime").setFloatContent(settings.mq_lifetime);
}

String color_to_string(color _c)
{
  return nf(red(_c)) + ", " + nf(green(_c)) + ", " + nf(blue(_c)) + ", " + nf(alpha(_c));
}