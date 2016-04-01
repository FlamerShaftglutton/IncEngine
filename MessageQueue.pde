class MessageQueue
{
  Message[] mq;
  int mq_size;
  float h;
  
  void add_message(String _message)
  {
    mq[mq_size] = new Message(_message, settings.mq_lifetime);
  }
  
  void display(float delta)
  {
    if (mq_size == 0)
      return;
    
    //first, delete any old ones
    int first_live = -1;
    for (int i = 0; i < mq_size; i++)
    {
      mq[i].lifetime -= delta;
      
      if (mq[i].lifetime > 0.0f && first_live < 0)
        first_live = i;
      
      if (first_live > 0)
        mq[i - first_live] = mq[i];
    }
    
    if (first_live > 0)
      mq_size -= first_live;
    
    //now draw them all
    float yy = settings.mq_text_size;
    for (int i = mq_size - 1; i >= 0; i--)
    {
      mq[i].display(settings.mq_text_size, yy);
      
      yy += settings.mq_text_size + mq[i].h;
    }
  }
}

class Message
{
  String[] text_lines;
  float  lifetime;
  float  h;
  
  Message(String _mtext, float _lifetime)
  {
    lifetime = _lifetime;
    
    StringList lines = new StringList();
    
    int ppos = 0;
    for (int pos = _mtext.indexOf(' '); pos < _mtext.length() && pos >= 0; pos = _mtext.indexOf(' ', pos + 1))
    {
      //TODO: test the width of the string
      
      //TODO: if it's too long, use ppos to make a substring. Add the substring to the list of lines and set _mtext to the rest of the string
    }
    
    //TODO: test the final substring
    
    text_lines = lines.array();
    h = lines.size() * settings.mq_text_size;
  }
  
  void display(float x, float y)
  {
    textSize(settings.mq_text_size);
    fill(settings.default_text_color);
    
    for (int i = 0; i < text_lines.length; i++)
      text(text_lines[i],x,y + (float)i * settings.mq_text_size);
  }
}