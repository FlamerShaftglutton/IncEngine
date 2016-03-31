Resource[] resources;
Button[] buttons;
ArrayList<Worker> workers;
Settings settings;

int dragged_worker_index;
PImage worker_sprite;

int player_type_index;
int crew_type_index;

int ptime;
int psavetime;

void setup()
{
  File f = new File(sketchPath("SavedGame.xml"));
  
  if (f.exists())
  {
    println("Found Save Game File, loading saved game");
    import_from_xml("SavedGame.xml");
  }
  else
  {
    println("Unable to find Saved Game file, loading new game");
    import_from_xml("NewGame.xml");
  }
  
  worker_sprite = loadImage(settings.worker_sprite_path);
  
  dragged_worker_index = -1;
  player_type_index = type_index_from_name("Player");
  crew_type_index = type_index_from_name("Crew");
  
  ptime = psavetime = 0;
  
  size(100,100);
  
  surface.setResizable(true);
  surface.setSize((int)settings.window_width,(int)settings.window_height);
  surface.setResizable(false);
}

void draw()
{
  int ctime = millis();
  
  background(settings.background_color);
  
  float delta = settings.time_multiplier * float(ctime - ptime) / 1000.0f;
  
  float y = 50.0f;
  for (Button b : buttons)
  {
    b.update(delta);
    
    if (b.visible && b.hideuntil == null)
    {
      b.y = y;
      y += 50.0f;
    }
    else
    {
      b.y = -100.0f;
    }
    
    b.display();
  }
  
  noTint();
  fill(settings.default_text_color);
  y = 50.0f;
  textSize(settings.default_text_size);
  for (Resource r : resources)
  {
    if (r.visible() || settings.debugging)
    {
      text(r.value + " " + r.get_name(), width - 200.0f, y);
      y += 50.0f;
    }
  }
  
  //create new workers (if need be)
  while (workers.size() < resources[crew_type_index].value)
  {
    workers.add(new Worker());
  }
  
  int num_inactive = 0;
  for (int i = 0; i < workers.size(); i++)
  {
    boolean assigned = false;
    for (int j = 0; j < buttons.length; j++)
    {
      if (buttons[j].myworkers.hasValue(i))
      {
        assigned = true;
        break;
      }
    }
    
    if (!assigned)
    {
      //return anything they may have spent at their last button position
      workers.get(i).return_click_stuff();
      
      //reposition it at the bottom of the screen
      workers.get(i).x = 50.0f + num_inactive * 1.5f * workers.get(i).w;
      workers.get(i).y = height - 50.0f - workers.get(i).w;
      workers.get(i).active = false;
      
      num_inactive++;
    }
  }
  
  if (dragged_worker_index >= 0)
  {
    workers.get(dragged_worker_index).x = mouseX - workers.get(dragged_worker_index).w / 2.0f;
    workers.get(dragged_worker_index).y = mouseY - workers.get(dragged_worker_index).h / 2.0f;
  }
  
  for (Worker w : workers)
    w.display();
  
  for (Button b : buttons)
  {
    if (b.display_tooltip(delta))
      break;
  }
  
  //save the game if necessary
  if (ctime - psavetime > 10000)
  {
    psavetime = ctime;
    println("Saving Game...");
    export_to_xml("SavedGame.xml");
    println("Done saving, time taken was ", millis() - ctime, " milliseconds");
  }
  ptime = ctime;
}

void mousePressed()
{
  dragged_worker_index = -1;
  
  for (int i = 0; i < workers.size(); i++)
  {
    if (workers.get(i).clicked())
    {
      dragged_worker_index = i;
      break;
    }
  }
}

void mouseReleased()
{
  if (dragged_worker_index >= 0)
  {
    for (int i = 0; i < buttons.length; i++)
    {
      buttons[i].dragged_crew(dragged_worker_index);
    }
    
    dragged_worker_index = -1;
  }
  else
  {
    for (int i = 0; i < buttons.length && !buttons[i].clicked(); i++);
  }
}