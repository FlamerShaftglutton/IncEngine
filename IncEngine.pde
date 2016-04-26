Resource[] resources;
Tab[] tabs;
//Button[] buttons;
ArrayList<Worker> workers;
Settings settings;
MessageQueue message_queue;

int current_tab_index;
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
    import_from_xml("SavedGame.xml");
    
    if (settings.debugging)
      println("Found Save Game File, loading saved game");
  }
  else
  {
    import_from_xml("NewGame.xml");
    
    if (settings.debugging)
      println("Unable to find Saved Game file, loading new game");
  }
  
  message_queue = new MessageQueue();
  
  worker_sprite = loadImage(settings.worker_sprite_path);
  
  dragged_worker_index = -1;
  current_tab_index = 0;
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
  //fill in the background
  fill(settings.background_color);
  rect(0,0,settings.window_width,settings.window_height);
  
  //calculate the time delta since the last frame
  int ctime = millis();
  float delta = settings.time_multiplier * float(ctime - ptime) / 1000.0f;
  
  //update and display the tab contents
  int num_tabs_visible = 0;
  for (int i = 0; i < tabs.length; i++)
  {
    tabs[i].update(delta);
    
    if (tabs[i].visible())
      num_tabs_visible++;
  }
  
  //if the tab we were currently on suddenly went dark, we need to move to the first visible one
  if (!tabs[current_tab_index].visible())
  {
    current_tab_index = 0;
    for (int i = 0; i < tabs.length; i++)
    {
      if (tabs[i].visible())
      {
        current_tab_index = i;
        break;
      }
    }
    
    if (settings.debugging)
      println("Warning: The current tab disappeared, moving to first visible tab.");
  }
  
  tabs[current_tab_index].display(delta);
  
  //draw the tab headers (if necessary)
  if (num_tabs_visible > 1 || settings.debugging)
  {
    float yy = settings.default_text_size;
    float xx = tabs[0].x;
    
    textSize(settings.default_text_size);
    
    for (int i = 0; i < tabs.length; i++)
    {
      if (tabs[i].visible())
      {
        //draw the title
        if (i == current_tab_index)
          fill(settings.default_text_color);
        else
          fill(settings.default_disabled_text_color);
        
        text(tabs[i].title, xx, yy);
        
        //move xx over for the next title to be drawn
        xx += textWidth(tabs[i].title) + 3.0f * settings.default_text_size;
      }
    }
  }
  
  //display the resources
  noTint();
  fill(settings.default_text_color);
  float y = settings.default_text_size * 2.0f;
  textSize(settings.default_text_size);
  for (Resource r : resources)
  {
    if (r.visible() || settings.debugging)
    {
      text(r.get_value() + " " + r.get_name(), width - 200.0f, y);
      y += settings.default_text_size * 1.5f;
    }
  }
  
  //create new workers (if need be)
  int num_crew = resources[crew_type_index].get_value();
  while (workers.size() < num_crew)
  {
    workers.add(new Worker());
  }
  
  //remove workers (if need be)
  while (workers.size() > num_crew)
  {
    for (int t = 0; t < tabs.length; t++)
    {
      for (int j = 0; j < tabs[t].buttons.length; j++)
      {
        for (int k = 0; k < tabs[t].buttons[j].myworkers.size(); k++)
        {
          if (tabs[t].buttons[j].myworkers.get(k) == workers.size() - 1)
          {
            tabs[t].buttons[j].myworkers.remove(k);
            break;
          }
        }
      }
    }
    
    //return anything they may have spent at their last button position
    workers.get(workers.size() - 1).return_click_stuff();
    workers.remove(workers.size() - 1);
  }
  
  //move the workers that are inactive
  int num_inactive = 0;
  for (int i = 0; i < workers.size(); i++)
  {
    if (!workers.get(i).assigned)
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
  
  //move the worker being dragged around
  if (dragged_worker_index >= 0)
  {
    
    workers.get(dragged_worker_index).x = mouseX - workers.get(dragged_worker_index).w / 2.0f;
    workers.get(dragged_worker_index).y = mouseY - workers.get(dragged_worker_index).h / 2.0f;
  }
  
  //now actually draw the workers that need drawn
  IntList assigned_to_current_tab = tabs[current_tab_index].get_workers();
  for (int i = 0; i < workers.size(); i++)
  {
    if (!workers.get(i).assigned || assigned_to_current_tab.hasValue(i))
      workers.get(i).display();
  }
  
  //draw the message queue
  message_queue.display(delta);
  
  //draw the tooltips of the buttons (which have to be over everything else)
  tabs[current_tab_index].display_tooltips(delta, mouseX, mouseY);
  
  //save the game if necessary
  if (ctime - psavetime > int(settings.autosave_time * 1000.0f))
  {
    psavetime = ctime;
    
    if (settings.debugging)
      println("Saving Game...");
    
    export_to_xml("SavedGame.xml");
    
    message_queue.add_message("Game Saved");
    
    if (settings.debugging)
      println("Done saving, time taken was ", millis() - ctime, " milliseconds");
  }
  
  //get ready for the next frame
  ptime = ctime;
}

void mousePressed()
{
  dragged_worker_index = -1;
  
  for (int i = 0; i < workers.size(); i++)
  {
    if (workers.get(i).clicked(mouseX, mouseY) && (!workers.get(i).assigned || tabs[current_tab_index].get_workers().hasValue(i)))
    {
      dragged_worker_index = i;
      break;
    }
  }
  
  //if we clicked on a tab header
  if (mouseY >= 0.0f && mouseY < tabs[0].y && mouseX > tabs[0].x && mouseX < tabs[0].x + tabs[0].w)
  {
    //run through each visible tab header to see if it was clicked
    float xx = tabs[0].x;
    textSize(settings.default_text_size);
    for (int i = 0; i < tabs.length; i++)
    {
      if (tabs[i].visible())
      {
        float tw = textWidth(tabs[i].title);
        
        if (mouseX >= xx && mouseX <= xx + tw)
        {
          current_tab_index = i;
          
          break;
        }
        
        xx += tw + 3.0f * settings.default_text_size;
      }
    }
  }
}

void mouseReleased()
{
  if (dragged_worker_index >= 0)
  {
    tabs[current_tab_index].dragged_worker(dragged_worker_index, mouseX, mouseY);
    
    dragged_worker_index = -1;
  }
  else
  {
    tabs[current_tab_index].clicked(mouseX, mouseY);
  }
}