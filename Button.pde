class Button
{
  String words;
  float x;
  float y;
  float w;
  float h;
  float text_height;
  
  color button_color;
  color outline_color;
  color text_color;
  color disabled_text_color;
  color cooldown_overlay_color;
  color cooldown_worker_overlay_color;
  
  boolean always_invisible;
  boolean visible;
  boolean enabled;
  
  boolean autoclick;
  
  String tooltip;
  float tooltip_time;
  boolean display_cost_in_tooltip;
  
  Cooldown cooldown;
  Prerequisite hideuntil;
  Prerequisite hideafter;
  Converter converter;
  
  IntList myworkers;
  
  Button(String _words, float _w, float _h, float _text_height, boolean _visible, boolean _always_invisible, boolean _enabled, boolean _autoclick, color _button_color, color _outline_color, color _text_color, color _disabled_text_color, color _cooldown_overlay_color, color _cooldown_worker_overlay_color)
  {
    words =_words;
    
    button_color = _button_color;
    outline_color = _outline_color;
    text_color = _text_color;
    disabled_text_color = _disabled_text_color;
    cooldown_overlay_color = _cooldown_overlay_color;
    cooldown_worker_overlay_color = _cooldown_worker_overlay_color;
    
    tooltip = "";
    display_cost_in_tooltip = false;
    
    text_height = _text_height;
    textSize(text_height);
    h = floor(text_height * 1.5f);
    w = floor(textWidth(words)) + h;
    x = y = -1000.0f;
    
    if (_w > w)
      w = _w;
    
    if (_h > h)
      h = _h;

    enabled = _enabled;
    visible = _visible;
    always_invisible = _always_invisible;
    autoclick = _autoclick;
    
    cooldown = null;
    hideuntil = null;
    converter = null;
    
    myworkers = new IntList();
  }
  
  Button(String _text)
  {
    this(_text, -1.0f, -1.0f, 32.0f, true, false, true, false, settings.default_button_color, settings.default_button_outline_color, settings.default_button_text_color, settings.default_disabled_text_color, settings.default_cooldown_overlay_color, settings.default_cooldown_worker_overlay_color);
  }
  
  void set_string(String _words)
  {
    words = _words;
    
    textSize(text_height);
    w = textWidth(_words) + h;
  }
  
  String get_string()
  {
    return words;
  }
  
  void display()
  {
    if (!visible || hideuntil != null || always_invisible)
      return;
      
    //draw the box
    noTint();
    stroke(outline_color);
    fill(button_color);
    rect(x,y,w,h);
    
    //draw the cooldown timer(s)
    if (cooldown != null)
    {
      if (!enabled && cooldown.current_amount > 0.0f)
      {
        noStroke();
        fill(cooldown_overlay_color);
        rect(x,y,w * cooldown.current_amount / cooldown.max_amount, h);
      }
      
      if (cooldown.current_worker_amount > 0.0f && myworkers.size() > 0)
      {
        noStroke();
        fill(cooldown_worker_overlay_color);
        rect(x,y + h * (1.0f - cooldown.current_worker_amount / cooldown.max_amount), w, h * cooldown.current_worker_amount / cooldown.max_amount);
      }
    }
    
    //draw the words
    fill(enabled ? text_color : disabled_text_color);
    textSize(text_height);
    text(words,x + (w - textWidth(words)) / 2.0f, y + text_height);
    
    //draw the worker count if necessary
    if (myworkers.size() >= 5)
    {
      fill(settings.default_text_color);
      textSize(text_height);
      float xx = x + w + workers.get(myworkers.get(0)).w * 2.25f;
      text("x" + myworkers.size(), xx, y + text_height);
    }
  }
  
  boolean display_tooltip(float _delta, float _mouseX, float _mouseY)
  {
    boolean needs_displayed = visible && _mouseX >= x && _mouseX <= x + w && _mouseY > y && _mouseY < y + h;
    
    if (needs_displayed)
    {
      tooltip_time += _delta;
      
      if (tooltip_time > 1.0f && !tooltip.equals(""))
      {
        textSize(text_height / 2.0f);
        
        float ttw = textWidth(tooltip);
        
        
        stroke(0);
        fill(255);
        
        float tth = 0.75f * text_height;
        String cost_string = "";
        
        if (display_cost_in_tooltip && converter != null)
        {
          cost_string = converter.click.to_evaluated_string();
          tth = 1.25f * text_height;
          ttw = max(ttw, textWidth(cost_string));
        }
        
        rect(_mouseX + 10.0f, _mouseY, ttw + 0.75f * text_height, tth);
        fill(0);
        text(tooltip, _mouseX + 10.0f + 0.375f * text_height, _mouseY + 0.5f * text_height);
        
        if (cost_string.length() > 0)
          text(cost_string, _mouseX + 10.0f + 0.375f * text_height, _mouseY + 1.0f * text_height);
      }
    }
    else
    {
      tooltip_time = 0.0f;
    }
    
    return needs_displayed;
  }
  
  void crew_click()
  {
    if (visible && converter != null)
    {
      boolean has_active_workers = false;
      for (int i = 0; i < myworkers.size(); i++)
      {
        //evaluate the list separately for each crewmember
        boolean has_costs = true;
        for (int j = 0; j < converter.click.types.length; j++)
        {
          if (converter.click.types[j] != player_type_index && resources[converter.click.types[j]].get_value() + converter.click.values[j].evaluate() < 0)
          {
            has_costs = false;
            break;
          }
        }
        
        if (!has_costs)
        {
          workers.get(myworkers.get(i)).active = false;
        }
        else
        {
          Worker w = workers.get(myworkers.get(i));
          w.active = true;
          w.click_paid = converter.click;
          w.pay_click_stuff();
          has_active_workers = true;
        }
      }
      
      if (cooldown != null)
      {
        if (has_active_workers)
          cooldown.current_worker_amount = cooldown.max_amount;
        else
          cooldown.current_worker_amount = 0.0f;
      }
      
      if (has_active_workers)
        message_queue.add_message(converter.click_message);
    }
  }
  
  void crew_reset()
  {
    if (visible && converter != null)
    {
      for (int i = 0; i < myworkers.size(); i++)
      {
        if (workers.get(myworkers.get(i)).active)
        {
          for (int j = 0; j < converter.reset.types.length; j++)
          {
            if (converter.reset.types[j] != player_type_index)
              resources[converter.reset.types[j]].add_value(converter.reset.values[j].evaluate());
          }
        }
        
        workers.get(myworkers.get(i)).click_paid = null;
      }
      
      message_queue.add_message(converter.reset_message);
    }
  }
  
  boolean dragged_crew(int _crew_index, float _mouseX, float _mouseY)
  {
    boolean dropped_here = visible && _mouseX >= x && _mouseX <= x + w && _mouseY > y && _mouseY < y + h;
    
    if (dropped_here && cooldown != null)
    {
      if (!myworkers.hasValue(_crew_index))//don't do anything if the worker was already here!
      {
        myworkers.append(_crew_index);
        
        //"get back" anything the worker may have paid for at his previous button position
        workers.get(_crew_index).return_click_stuff();
        
        if (myworkers.size() > 1)
          workers.get(_crew_index).active = false;

        else
          crew_click();
      }
    }
    else
    {
      //if the worker isn't being dropped on this button, but this button is carrying it, remove it!
      for (int i = 0; i < myworkers.size(); i++)
      {
        if (myworkers.get(i) == _crew_index)
        {
          myworkers.remove(i);
          break;
        }
      }
      
      //if we are now empty, reset the worker cooldown
      if (myworkers.size() == 0 && cooldown != null)
      {
        cooldown.current_worker_amount = 0.0f;
      }
    }
    
    return dropped_here;
  }
  
  boolean update(float delta)
  {
    boolean retval = false;
    enabled = true;
    
    //check if we can drop the hideuntil
    if (hideuntil != null)
    {
      //check if the hideuntils have been met
      boolean met = hideuntil.met();
      if (met)
      {
        hideuntil = null;
      }
      
      visible = met;
      enabled = met;
      retval = true;
    }
    
    //check if we can drop the hideafter
    if (hideafter != null)
    {
      //check if the hideuntils have been met
      if (hideafter.met())
      {
        //return everything the user put in
        if (cooldown != null && converter != null && converter.click != null && cooldown.current_amount > 0.0f)
        {
          for (int j = 0; j < converter.click.types.length; j++)
          {
            resources[converter.click.types[j]].add_value(-converter.click.values[j].evaluate());
          }
        }
        
        //set our flags
        hideafter = null;
        visible = false;
        hideuntil = null;
        enabled = false;
        autoclick = false;
        converter = null;
        
        //also, kick out everyone working on this button!
        for (int i = 0; i < myworkers.size(); i++)
        {
          //'get back' everything this crewmember paid for
          workers.get(myworkers.get(i)).return_click_stuff();
          workers.get(myworkers.get(i)).assigned = false;
        }
        myworkers.clear();
        
        retval = true;
      }
    }
    
    //do cooldown stuff
    if (cooldown != null)
    {
      if (myworkers.size() > 0)
      {
        //first, we need to check if any of the workers are active!
        boolean has_active_workers = false;
        for (int i = 0; i < myworkers.size(); i++)
        {
          if (workers.get(myworkers.get(i)).active)
          {
            has_active_workers = true;
            break;
          }
        }
        
        if (has_active_workers)
        {
          cooldown.current_worker_amount -= delta;
          
          if (cooldown.current_worker_amount <= 0.0f)
          {
            cooldown.current_worker_amount = 0.0f;
            crew_reset();
            crew_click();
          }
        }
        else
        {
          crew_click();
        }
      }
      
      if (cooldown.current_amount > 0.0f)
      {
        cooldown.current_amount -= delta;
        
        if (cooldown.current_amount <= 0.0f)
        {
          cooldown.current_amount = 0.0f;
          enabled = true;
          on_reset();
        }
        else
        {
          enabled = false;
        }
      }
    }
    
    //determine if this should be enabled or not
    if (converter != null && enabled)
    {
      for (int i = 0; i < converter.click.types.length; i++)
      {
        if (resources[converter.click.types[i]].get_value() + converter.click.values[i].evaluate() < 0)
        {
          enabled = false;
          break;
        }
      }
    }
    
    //do autoclicking if necessary
    if (autoclick && enabled)
      on_click();
    
    //return the dirty flag
    return retval;
  }
  
  void update_position(float _x, float _y)
  {
    x = _x;
    y = _y;
    
    //move this button's workers around so that they are drawn in the right places
    if (myworkers.size() >= 5)
    {
      float yy = y + (h - workers.get(myworkers.get(0)).h) / 2.0f;
      float xx = x + w + workers.get(myworkers.get(0)).w * 0.75f;
      for (int i = 0; i < myworkers.size(); i++)
      {
        workers.get(myworkers.get(i)).y = yy;
        workers.get(myworkers.get(i)).x = xx;
      }
    }
    else
    {
      for (int i = 0; i < myworkers.size(); i++)
      {
        workers.get(myworkers.get(i)).y = y + (h - workers.get(myworkers.get(i)).h) / 2.0f;
        workers.get(myworkers.get(i)).x = x + w + workers.get(myworkers.get(i)).w * 1.5f * (i + 0.5f);
      }
    }
  }
  
  boolean clicked(float _mouseX, float _mouseY)
  {
    boolean was_clicked = visible && enabled && _mouseX >= x && _mouseX <= x + w && _mouseY > y && _mouseY < y + h;

    if (was_clicked)
    {
      on_click();
    }
    
    return (was_clicked);
  }
  
  void on_click()
  {
    boolean met = cooldown == null || cooldown.current_amount <= 0.0f;
    if (converter != null && converter.click != null)
    {
      //first off, make sure we meet the requirements (this is normally covered in the 'update' step, but this covers all edge cases
      for (int i = 0; i < converter.click.types.length && met; i++)
      {
        met &= resources[converter.click.types[i]].get_value() + converter.click.values[i].evaluate() >= 0;
      }
    
      if (met)
      {
        for (int i = 0; i < converter.click.types.length; i++)
        {
          resources[converter.click.types[i]].add_value(converter.click.values[i].evaluate());
        }
        
        message_queue.add_message(converter.click_message);
      }
    }
    
    if (cooldown != null && met)
    {
      enabled = false;
      cooldown.current_amount = cooldown.max_amount;
    }
  }
  
  void on_reset()
  {
    if (converter != null && converter.reset != null)
    {
      for (int i = 0; i < converter.reset.types.length; i++)
      {
        resources[converter.reset.types[i]].add_value(converter.reset.values[i].evaluate());
      }
      
      message_queue.add_message(converter.reset_message);
    }
  }
}


class Cooldown
{
  float current_amount; //in seconds
  float current_worker_amount;
  float max_amount;
  boolean display;
  
  Cooldown(float _current_amount, float _max_amount, boolean _display, float _current_worker_amount)
  {
    current_amount = _current_amount;
    current_worker_amount = _current_worker_amount;
    max_amount = _max_amount;
    display = _display;
  }
  
  Cooldown(float _max_amount)
  {
    this(0.0f, _max_amount, true, 0.0f);
  }
}

class Prerequisite
{
  ResourceSet list;
  boolean all;
  boolean alltime;
  
  Prerequisite(ResourceSet _list, boolean _all, boolean _alltime)
  {
    list = _list;
    
    all = _all;
    alltime = _alltime;
  }
  
  Prerequisite(String _input, boolean _all, boolean _alltime)
  {
    this(new ResourceSet(_input), _all, _alltime);
  }
  
  boolean met()
  {
    for (int i = 0; i < list.types.length; i++)
    {
      if (all)
      {
        if (resources[list.types[i]].get_alltime_amount() < list.values[i].evaluate())
          return false;
      }
      else
      {
        if (resources[list.types[i]].get_alltime_amount() >= list.values[i].evaluate())
          return true;
      }
    }
      
    return all;
  }
}

class Converter
{
  ResourceSet click;
  ResourceSet reset;
  
  String click_message;
  String reset_message;
  
  Converter(ResourceSet _click, ResourceSet _reset, String _click_message, String _reset_message)
  {
    click = _click;
    reset = _reset;
    
    click_message = _click_message;
    reset_message = _reset_message;
  }
  
  Converter(String _click, String _reset, String _click_message, String _reset_message)
  {
    click = _click.equals("") ? null : new ResourceSet(_click);
    reset = _reset.equals("") ? null : new ResourceSet(_reset);
    
    click_message = _click_message;
    reset_message = _reset_message;
  }
}