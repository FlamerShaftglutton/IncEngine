void import_from_xml(String _filename)
{
  XML xml = loadXML(_filename);
  
  XML xsettings = xml.getChild("settings");
  XML xresources = xml.getChild("resources");
  XML xworkers = xml.getChild("workers");
  XML xbuttons = xml.getChild("buttons");
  
  import_settings_from_xml(xsettings);//it's important that this goes first!
  import_resources_from_xml(xresources);
  import_workers_from_xml(xworkers);
  import_buttons_from_xml(xbuttons);
}

void import_settings_from_xml(XML xml)
{
  float default_text_size = 32.0f;
  color default_button_text_color = #000000;
  color default_text_color = #FFFFFF;
  color default_button_color = #FFFFFF;
  color default_button_outline_color = #000000;
  color default_disabled_text_color = #B7B7B7;
  color default_cooldown_overlay_color = color(0,0,0,200);
  color default_cooldown_worker_overlay_color = color(0,0,0,100);
  color background_color = color(50,50,50);
  String worker_sprite_path = "worker.png";
  boolean debugging = false;
  float time_multiplier = 1.0f;
  float window_width = 1000.0f;
  float window_height = 800.0f;
  float mq_width = 100.0f;
  float mq_text_size = 14.0f;
  float mq_lifetime = 10.0f;
  
  if (xml != null)
  {
    XML[] kids = xml.getChildren();
    
    for (XML kid : kids)
    {
      String n = kid.getName();
      
      if (n.equals("default_text_size"))
        default_text_size = kid.getFloatContent();
      else if (n.equals("default_text_color"))
        default_text_color = string_to_color(kid.getContent());
      else if (n.equals("default_button_text_color"))
        default_button_text_color = string_to_color(kid.getContent());
      else if (n.equals("default_button_color"))
        default_button_color = string_to_color(kid.getContent());
      else if (n.equals("default_button_outline_color"))
        default_button_outline_color = string_to_color(kid.getContent());
      else if (n.equals("default_disabled_text_color"))
        default_disabled_text_color = string_to_color(kid.getContent());
      else if (n.equals("default_cooldown_overlay_color"))
        default_cooldown_overlay_color = string_to_color(kid.getContent());
      else if (n.equals("default_cooldown_worker_overlay_color"))
        default_cooldown_worker_overlay_color = string_to_color(kid.getContent());
      else if (n.equals("background_color"))
        background_color = string_to_color(kid.getContent());
      else if (n.equals("worker_sprite_path"))
        worker_sprite_path = kid.getContent();
      else if (n.equals("debugging"))
        debugging = kid.getContent().equals("true");
      else if (n.equals("time_multiplier"))
        time_multiplier = kid.getFloatContent();
      else if (n.equals("window_width"))
        window_width = kid.getFloatContent();
      else if (n.equals("window_height"))
        window_height = kid.getFloatContent();
      else if (n.equals("mq_width"))
        mq_width = kid.getFloatContent();
      else if (n.equals("mq_text_size"))
        mq_text_size = kid.getFloatContent();
      else if (n.equals("mq_lifetime"))
        mq_lifetime = kid.getFloatContent();
    }
  }
  
  settings = new Settings();
  settings.default_text_size = default_text_size;
  settings.default_text_color = default_text_color;
  settings.default_button_text_color = default_button_text_color;
  settings.default_button_color = default_button_color;
  settings.default_button_outline_color = default_button_outline_color;
  settings.default_disabled_text_color = default_disabled_text_color;
  settings.default_cooldown_overlay_color = default_cooldown_overlay_color;
  settings.default_cooldown_worker_overlay_color = default_cooldown_worker_overlay_color;
  settings.background_color = background_color;
  settings.worker_sprite_path = worker_sprite_path;
  settings.debugging = debugging;
  settings.time_multiplier = time_multiplier;
  settings.window_width = window_width;
  settings.window_height = window_height;
  settings.mq_width = mq_width;
  settings.mq_text_size = mq_text_size;
  settings.mq_lifetime = mq_lifetime;
}

void import_resources_from_xml(XML xml)
{
  if (xml == null)
    return;
  
  XML[] xresources = xml.getChildren("resource");
  
  resources = new Resource[xresources.length];
  for (int i = 0; i < xresources.length; i++)
  {
    String singular_name   = "";
    String plural_name     = "";
    int    min_value       = 0;
    int    value           = 0;
    int    alltime_amount = 0;
    
    String[] chunks = split(xresources[i].getContent(), ",");
    singular_name = trim(chunks[0]);
   
    if (chunks.length > 1)
      plural_name = trim(chunks[1]);
    else
      plural_name = trim(chunks[0]);
    
    if (xresources[i].hasAttribute("min"))
      min_value = xresources[i].getInt("min");
    
    if (xresources[i].hasAttribute("value"))
      value = xresources[i].getInt("value");
    
    if (xresources[i].hasAttribute("all_time"))
      alltime_amount = xresources[i].getInt("alltime");
    
    resources[i] = new Resource(min_value,value,singular_name,plural_name, max(alltime_amount,value));
  }
}

void import_buttons_from_xml(XML xml)
{
  if (xml == null)
    return;
  
  XML[] xbuttons = xml.getChildren("button");
  
  buttons = new Button[xbuttons.length];
  for (int i = 0; i < xbuttons.length; i++)
  {
    String  title = "?";
    String  tooltip = "";
    
    float   x = xbuttons[i].getFloat("x",settings.default_text_size + settings.mq_width);
    float   y = xbuttons[i].getFloat("y",float(i + 1) * settings.default_text_size * 1.5f);
    float   w = xbuttons[i].getFloat("width",-1.0f);
    float   h = xbuttons[i].getFloat("height",-1.0f);
    float   text_height = xbuttons[i].getFloat("text_height",1.0f);
    boolean visible = xbuttons[i].getString("visible","true").equals("true");
    boolean enabled = xbuttons[i].getString("enabled","true").equals("true");
    boolean autoclick = xbuttons[i].getString("autoclick","false").equals("true");
    color   button_color = string_to_color(xbuttons[i].getString("button_color",color_to_string(settings.default_button_color)));
    color   outline_color = string_to_color(xbuttons[i].getString("outline_color",color_to_string(settings.default_button_outline_color)));
    color   text_color = string_to_color(xbuttons[i].getString("text_color",color_to_string(settings.default_button_text_color)));
    color   disabled_text_color = string_to_color(xbuttons[i].getString("disabled_text_color",color_to_string(settings.default_disabled_text_color)));
    color   cooldown_overlay_color = string_to_color(xbuttons[i].getString("cooldown_overlay_color",color_to_string(settings.default_cooldown_overlay_color)));
    color   cooldown_worker_overlay_color = string_to_color(xbuttons[i].getString("cooldown_worker_overlay_color",color_to_string(settings.default_cooldown_worker_overlay_color)));
    
    boolean cooldown = false;
    float   cooldown_max_amount = 0.0f;
    float   cooldown_current_amount = 0.0f;
    float   cooldown_worker_amount = 0.0f;
    boolean cooldown_display = true;
    
    boolean converter = false;
    String  click_innards = "";
    String  reset_innards = "";
    String  click_message = "";
    String  reset_message = "";
    
    boolean hideuntil = false;
    String  hideuntil_innards = "";
    boolean hideuntil_all = false;
    
    boolean hideafter = false;
    String  hideafter_innards = "";
    boolean hideafter_all = false;
    
    IntList worker_list = new IntList();
    
    //loop through each child and find some stuff
    XML[] kids = xbuttons[i].getChildren();
    
    for (XML kid : kids)
    {
      String n = kid.getName();
      
      if (n.equals("title"))
        title = kid.getContent();
      else if (n.equals("cooldown"))
      {
        cooldown = true;
        if (kid.listChildren().length > 1)
        {
          XML kdisplay = kid.getChild("display");
          XML kworker_amount = kid.getChild("worker_amount");
          XML kcurrent_amount = kid.getChild("current_amount");
          XML kmax_amount = kid.getChild("max_amount");
          
          if (kdisplay != null)
            cooldown_display = kdisplay.getContent().equals("true");
          
          if (kworker_amount != null)
            cooldown_worker_amount = kworker_amount.getFloatContent();
          
          if (kcurrent_amount != null)
            cooldown_current_amount = kcurrent_amount.getFloatContent();
          
          if (kmax_amount != null)
            cooldown_max_amount = kmax_amount.getFloatContent();
        }
        else
        {
          cooldown_max_amount = kid.getFloatContent();
        }
      }
      else if (n.equals("hideuntil"))
      {
        hideuntil = true;
        hideuntil_innards = kid.getContent();
        hideuntil_all = kid.getString("all","false").equals("true");
      }
      else if (n.equals("hideafter"))
      {
        hideafter = true;
        hideafter_innards = kid.getContent();
        hideafter_all = kid.getString("all","false").equals("true");
      }
      else if (n.equals("tooltip"))
      {
        tooltip = kid.getContent();
      }
      else if (n.equals("converter"))
      {
        converter = true;
        XML kclick = kid.getChild("click");
        XML kreset = kid.getChild("reset");
        
        if (kclick != null)
        {
          click_innards = kclick.getContent();
          click_message = kclick.getString("message","");
        }
        
        if (kreset != null)
        {
          reset_innards = kreset.getContent();
          reset_message = kreset.getString("message","");
        }
      }
      else if (n.equals("workers"))
      {
        String[] worker_indexes = trim(split(kid.getContent(),","));
        
        for (String wo : worker_indexes)
        {
          if (!wo.equals(""))
            worker_list.append(parseInt(wo));
        }
      }
    }
    
    //now construct the button
    buttons[i] = new Button(title, x, y, w, h, text_height * settings.default_text_size, visible, enabled, autoclick, button_color, outline_color, text_color, disabled_text_color, cooldown_overlay_color, cooldown_worker_overlay_color);
    buttons[i].tooltip = tooltip;
    
    if (cooldown)
      buttons[i].cooldown = new Cooldown(cooldown_current_amount,cooldown_max_amount,cooldown_display,cooldown_worker_amount);
    
    if (hideuntil)
      buttons[i].hideuntil = new Prerequisite(hideuntil_innards,hideuntil_all);
      
    if (hideafter)
      buttons[i].hideafter = new Prerequisite(hideafter_innards,hideafter_all);
    
    if (converter)
      buttons[i].converter = new Converter(click_innards, reset_innards, click_message, reset_message);
    
    buttons[i].myworkers = worker_list;
  }
}

void import_workers_from_xml(XML xml)
{
  if (xml == null)
  {
    workers = new ArrayList<Worker>();
    return;
  }
  
  XML[] xworkers = xml.getChildren("worker");
  
  workers = new ArrayList<Worker>(xworkers.length);
  for (int i = 0; i < xworkers.length; i++)
    workers.add(new Worker());
  
  for (int i = 0; i < xworkers.length; i++)
  {
    int index = i;
    float wx = 0.0f;
    float wy = 0.0f;
    float wh = 32.0f;
    float ww = 32.0f;
    boolean wactive = false;
    String wclick_paid = "";
    
    XML[] kids = xworkers[i].getChildren();
    
    for (XML kid : kids)
    {
      String n = kid.getName();
      
      if (n.equals("index"))
        index = kid.getIntContent();
      else if (n.equals("x"))
        wx = kid.getFloatContent();
      else if (n.equals("y"))
        wy = kid.getFloatContent();
      else if (n.equals("width"))
        ww = kid.getFloatContent();
      else if (n.equals("height"))
        wh = kid.getFloatContent();
      else if (n.equals("active"))
        wactive = kid.getContent().equals("true");
      else if (n.equals("click_paid"))
        wclick_paid = kid.getContent();
    }
    
    Worker w = workers.get(index);
    w.x = wx;
    w.y = wy;
    w.w = ww;
    w.h = wh;
    w.active = wactive;
    if (wclick_paid.equals(""))
      w.click_paid = null;
    else
      w.click_paid = new ResourceSet(wclick_paid);
  }
}

color string_to_color(String _s)
{
  String[] chunks = trim(split(_s,","));
  
  if (chunks.length < 3)
    return color(0);
  
  if (chunks.length == 3)
    return color(parseInt(chunks[0]), parseInt(chunks[1]), parseInt(chunks[2]));
  
  return color(parseInt(chunks[0]), parseInt(chunks[1]), parseInt(chunks[2]), parseInt(chunks[3]));
}