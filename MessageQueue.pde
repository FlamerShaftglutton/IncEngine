class MessageQueue
{
  Message[] mq;
  int mq_size;
  float h;
  
  MessageQueue()
  {
    mq = new Message[10];
    mq_size = 0;
    h = height * 0.75f;
  }
  
  void add_message(String _message)
  {
    if (_message == null || _message.length() == 0 || (mq_size > 0 && _message.equals(mq[mq_size - 1].original_text)))
      return;
    
    if (mq_size == mq.length)
    {
      //shift everyone down a space, destroying the oldest
      for (int i = 1; i < mq.length; i++)
        mq[i-1] = mq[i];
      
      --mq_size;
    }
    
    mq[mq_size] = new Message(_message, settings.mq_lifetime, settings.mq_width - 2.0f * settings.mq_text_size);
    ++mq_size;
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
    
    if (first_live >= 0)
      mq_size -= first_live;
    else
      mq_size = 0;
    
    //now draw them all
    float yy = settings.mq_text_size * 2;
    for (int i = mq_size - 1; i >= 0; i--)
    {
      mq[i].display(settings.mq_text_size, yy);
      
      yy += settings.mq_text_size + mq[i].h;
    }
  }
}

class Message
{
  String original_text;
  String[] text_lines;
  float  lifetime;
  float  max_lifetime;
  float  h;
  
  Message(String _mtext, float _lifetime, float _effective_width)
  {
    lifetime = max_lifetime = _lifetime;
    original_text = _mtext;
    textSize(settings.mq_text_size);
    
    StringList lines = new StringList();
    
    int ppos = 0;
    int pos = 0;
    
    while (_mtext.length() > 0)
    {
      pos = _mtext.indexOf(' ', pos + 1);
      if (pos < 0)
        pos = _mtext.length();
      
      if (textWidth(_mtext.substring(0,pos)) > _effective_width)
      {
        //if it's just one long word, spit it out anyway and let the user grumble
        if (ppos == 0)
          ppos = pos;
        
        lines.append(trim(_mtext.substring(0,ppos)));
        _mtext = trim(_mtext.substring(ppos));
        ppos = pos = 0;
      }
      else if (pos == _mtext.length())
      {
        lines.append(trim(_mtext));
        _mtext = "";
      }
      else
        ppos = pos;
    }
    
    text_lines = lines.array();
    h = lines.size() * settings.mq_text_size;
  }
  
  void display(float x, float y)
  {
    tint(255);
    textSize(settings.mq_text_size);
    fill(settings.default_text_color, constrain(lifetime / max_lifetime,0.0f, 1.0f) * 255.0f);
    
    for (int i = 0; i < text_lines.length; i++)
      text(text_lines[i],x,y + (float)i * settings.mq_text_size);
  }
}