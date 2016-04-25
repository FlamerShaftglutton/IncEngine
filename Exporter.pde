void export_to_xml(String _filename)
{
  XML root = new XML("game");
  
  export_resources_to_xml(root);
  export_tabs_to_xml(root);
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
    r.setInt("value",resources[i].get_value());
    r.setInt("min",resources[i].min_to_display);
    r.setInt("alltime",resources[i].get_alltime_amount());
  }
}

void export_tabs_to_xml(XML root)
{
  XML ts = root.addChild("tabs");
  
  for (int t = 0; t < tabs.length; t++)
  {
    ts.addChild("title").setContent(tabs[t].title);
    ts.addChild("index").setContent(str(t));
    
    XML bs = ts.addChild("buttons");
    
    for (int i = 0; i < tabs[t].buttons.length; i++)
    {
      XML b = bs.addChild("button");
      
      b.setFloat("width", tabs[t].buttons[i].w);
      b.setFloat("height", tabs[t].buttons[i].h);
      b.setFloat("text_height", tabs[t].buttons[i].text_height / settings.default_text_size);
      b.setString("visible", tabs[t].buttons[i].visible ? "true" : "false");
      b.setString("enabled", tabs[t].buttons[i].enabled ? "true" : "false");
      
      if (tabs[t].buttons[i].always_invisible)
        b.setString("autoclick","invisible");
      else if (tabs[t].buttons[i].autoclick)
        b.setString("autoclick","true");
      
          
      b.addChild("title").setContent(tabs[t].buttons[i].get_string());
      if (!tabs[t].buttons[i].tooltip.equals(""))
      {
        XML ttc = b.addChild("tooltip");
        ttc.setContent(tabs[t].buttons[i].tooltip);
        if (tabs[t].buttons[i].display_cost_in_tooltip != settings.display_cost_in_tooltip)
          ttc.setString("display_cost","true");
      }
      
      if (tabs[t].buttons[i].cooldown != null)
      {
        XML c = b.addChild("cooldown");
        
        c.addChild("current_amount").setFloatContent(tabs[t].buttons[i].cooldown.current_amount);
        c.addChild("worker_amount").setFloatContent(tabs[t].buttons[i].cooldown.current_worker_amount);
        c.addChild("max_amount").setFloatContent(tabs[t].buttons[i].cooldown.max_amount);
        c.addChild("display").setContent(tabs[t].buttons[i].cooldown.display ? "true" : "false");
      }
      
      if (tabs[t].buttons[i].hideuntil != null)
      {
        XML cc = b.addChild("hideuntil");
        cc.setContent(tabs[t].buttons[i].hideuntil.list.to_string());
        cc.setString("all",tabs[t].buttons[i].hideuntil.all ? "true" : "false");
        cc.setString("alltime",tabs[t].buttons[i].hideuntil.alltime ? "true" : "false");
      }
      
      if (tabs[t].buttons[i].hideafter != null)
      {
        XML cc = b.addChild("hideafter");
        cc.setContent(tabs[t].buttons[i].hideafter.list.to_string());
        cc.setString("all",tabs[t].buttons[i].hideafter.all ? "true" : "false");
        cc.setString("alltime",tabs[t].buttons[i].hideafter.alltime ? "true" : "false");
      }
      
      if (tabs[t].buttons[i].converter != null)
      {
        if (tabs[t].buttons[i].converter.click != null || !tabs[t].buttons[i].converter.click_message.equals(""))
        {
          XML cc = b.addChild("click");
          
          if (tabs[t].buttons[i].converter.click != null)
            cc.setContent(tabs[t].buttons[i].converter.click.to_string());
            
          if (!tabs[t].buttons[i].converter.click_message.equals(""))
            cc.setString("message",tabs[t].buttons[i].converter.click_message);
        }
        
        if (tabs[t].buttons[i].converter.reset != null || !tabs[t].buttons[i].converter.reset_message.equals(""))
        {
          XML cc = b.addChild("reset");
          
          if (tabs[t].buttons[i].converter.reset != null)
            cc.setContent(tabs[t].buttons[i].converter.reset.to_string());
            
          if (!tabs[t].buttons[i].converter.reset_message.equals(""))
            cc.setString("message",tabs[t].buttons[i].converter.reset_message);
        }
      }
      
      if (tabs[t].buttons[i].myworkers != null && tabs[t].buttons[i].myworkers.size() > 0)
        b.addChild("workers").setContent(join(nf(tabs[t].buttons[i].myworkers.array(), 0), ","));
    }
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
  s.addChild("display_cost_in_tooltip").setContent(settings.display_cost_in_tooltip ? "true" : "false");
}

String color_to_string(color _c)
{
  return nf(red(_c)) + ", " + nf(green(_c)) + ", " + nf(blue(_c)) + ", " + nf(alpha(_c));
}