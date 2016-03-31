
int type_index_from_name(String name)
{
  name = trim(name);
  
  for (int i = 0; i < resources.length; i++)
  {
    if (resources[i].singular_name.equals(name) || resources[i].plural_name.equals(name))
      return i;
  }
  
  return -1;
}

class Resource
{
  boolean display;
  int value;
  String singular_name;
  String plural_name;
  int min_to_display;
  
  Resource(int _min_to_display, int _value, String _singular_name, String _plural_name)
  {
    display = _value >= _min_to_display;
    value = _value;
    singular_name = _singular_name;
    plural_name = _plural_name;
    min_to_display = _min_to_display;
  }
  
  String get_name()
  {
    return value > 1 ? plural_name : singular_name;
  }
  
  boolean visible()
  {
    display |= value >= min_to_display;
    return display;
  }
}

class ResourceSet
{
  int[] types;
  ResourceValue[] values;
  
  ResourceSet(int[] _types, ResourceValue[] _values)
  {
    types = _types;
    values = _values;
  }
  
  ResourceSet(int[] _types, int[] _values)
  {
    types = _types;
    
    values = new ResourceValue[_values.length];
    
    for (int i = 0; i < _values.length; i++)
    {
      values[i] = new ResourceValue(_values[i]);
    }
  }
  
  ResourceSet(String _input)
  {
    //the random(x,y) calls throw off our splitting by comma, so we need to address that first
    _input = _input.replaceAll("\\(([^,]+),([^,]+)\\)", "($1;$2)");
    String[] chunks = trim(split(_input, ','));
    
    types = new int[chunks.length];
    values = new ResourceValue[chunks.length];
    
    for (int i = 0; i < chunks.length; i++)
    {
      int pos;
      for (pos = 1; pos < chunks[i].length() && pos > 0; pos++)
      {
        if (chunks[i].charAt(pos) == '(')
          pos = chunks[i].indexOf(')',pos);
        else if (chunks[i].charAt(pos) == ' ')
          break;
      }
      String cc0 = trim(chunks[i].substring(0,pos));
      String cc1 = trim(chunks[i].substring(pos));
      String[] cc = splitTokens(cc0, "();");
      
      //if we got more than 1 token, this is probably a random
      if (cc.length > 1)
      {
        if (cc[0].equals("random"))
        {
          int mi = parseInt(trim(cc[1]));
          int ma = parseInt(trim(cc[2]));
          
          values[i] = new RandomResourceValue(mi,ma);
        }
        else
        {
          println("Error parsing xml: string had too many tokens");
        }
      }
      else
      {
        values[i] = new ResourceValue(int(cc[0]));
      }
      
      //figure out which resource type this is
      types[i] = type_index_from_name(cc1);
    }
  }
  
  String to_string()
  {
    String[] derps = new String[types.length];
    //String retval = "";
    for (int i = 0; i < types.length; i++)
    {
      derps[i] = values[i].to_string() + " " + resources[types[i]].plural_name;
      //retval += " " + values[i].to_string() + " " + resources[types[i]].plural_name + ",";
    }
    
    return join(derps, ", ");
  }
}

class ResourceValue
{
  int value;
  
  ResourceValue(int _value)
  {
    value = _value;
  }
  
  int evaluate()
  {
    return value;
  }
  
  String to_string()
  {
    return str(value);
  }
}

class RandomResourceValue extends ResourceValue
{
  int min_val;
  int max_val;
  
  RandomResourceValue(int _min, int _max)
  {
    super(0);
    min_val = _min;
    max_val = _max;
  }
  
  int evaluate()
  {
    return (int)random(min_val, max_val);
  }
  
  String to_string()
  {
    return "random("+str(min_val)+","+str(max_val)+")";
  }
}