class Tab
{
  String title;
  Button[] buttons;
  float x;
  float y;
  float w;
  float h;
  
  boolean dirty_flag;
  
  Tab(String _title, Button[] _buttons, float _x, float _y, float _w, float _h)
  {
    title = _title;
    buttons = _buttons;
    
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    
    dirty_flag = true;
  }
  
  boolean visible()
  {
    for (Button b : buttons)
    {
      if (b.visible)
        return true;
    }
    
    return false;
  }
  
  void update(float _delta)
  {
    //run each button's update function, catching a returned dirty flag if necessary
    for (int i = 0; i < buttons.length; i++)
    {
      dirty_flag |= buttons[i].update(_delta);
    }
    
    //update the positions of each button (if necessary)
    if (dirty_flag)
    {
      float yy = settings.default_text_size + y;
      float xx = settings.default_text_size + x;
      
      for (int i = 0; i < buttons.length; i++)
      {
        buttons[i].update_position(xx,yy);
        
        yy += 2.0f * settings.default_text_size;
      }
      
      dirty_flag = false;
    }
  }
  
  void display(float _delta, float _mouseX, float _mouseY)
  {
    //update and draw
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].update(_delta);
      
      if (buttons[i].visible && buttons[i].hideuntil == null && !buttons[i].always_invisible)
      {
        buttons[i].display();
      }
    }
    
    //tooltips
    for (int i = 0; i < buttons.length; i++)
    {
      if (buttons[i].visible && buttons[i].hideuntil == null && !buttons[i].always_invisible)
      {
        buttons[i].display_tooltip(_delta, _mouseX, _mouseY);
      }
    }
  }
  
  void clicked(float _mouseX, float _mouseY)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      if (buttons[i].visible && buttons[i].hideuntil == null && !buttons[i].always_invisible)
      {
        if (buttons[i].clicked(_mouseX, _mouseY))
          break;
      }
    }
  }
  
  void dragged_worker(int _worker_index, float _mouseX, float _mouseY)
  {
    workers.get(_worker_index).assigned = false;
    
    for (int i = 0; i < buttons.length; i++)
    {
      if (buttons[i].visible && buttons[i].hideuntil == null && !buttons[i].always_invisible)
      {
        if (buttons[i].dragged_crew(_worker_index, _mouseX, _mouseY))
        {
          workers.get(_worker_index).assigned = true;
          break;
        }
      }
    }
    
    dirty_flag = true;
  }
}