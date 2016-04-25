class Worker
{
  float x;
  float y;
  float w;
  float h;
  
  boolean active;
  boolean assigned;
  
  ResourceSet click_paid;
  
  Worker()
  {
    x = 0.0f;
    y = 0.0f;
    w = h = 32.0f;
    active = false;
    
    click_paid = null;
    assigned = false;
  }
  
  boolean clicked(float _mouseX, float _mouseY)
  {
    return _mouseX >= x && _mouseY >= y && _mouseX < x + w && _mouseY < y + h;
  }
  
  void display()
  {
    if (active)
      tint(255);
    else
      tint(150);
    
    image(worker_sprite,x,y);
  }
  
  void return_click_stuff()
  {
    if (click_paid != null)
    {
      for (int j = 0; j < click_paid.types.length; j++)
      {
        if (click_paid.types[j] != player_type_index)
          resources[click_paid.types[j]].add_value(-click_paid.values[j].evaluate());
      }
      
      click_paid = null;
    }
  }
  
  void pay_click_stuff()
  {
    if (click_paid != null)
    {
      for (int j = 0; j < click_paid.types.length; j++)
      {
        if (click_paid.types[j] != player_type_index)
          resources[click_paid.types[j]].add_value(click_paid.values[j].evaluate());
      }
    }
  }
}