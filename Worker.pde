class Worker
{
  float x;
  float y;
  float w;
  float h;
  
  boolean active;
  
  ResourceSet click_paid;
  
  Worker()
  {
    x = 0.0f;
    y = 0.0f;
    w = h = 32.0f;
    active = false;
    
    click_paid = null;
  }
  
  boolean clicked()
  {
    return mouseX >= x && mouseY >= y && mouseX < x + w && mouseY < y + h;
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
          resources[click_paid.types[j]].value -= click_paid.values[j].evaluate();
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
          resources[click_paid.types[j]].value += click_paid.values[j].evaluate();
      }
    }
  }
}