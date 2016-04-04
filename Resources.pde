
int type_index_from_name(String name)
{
  name = trim(name);
  
  for (int i = 0; i < resources.length; i++)
  {
    if (resources[i].singular_name.equals(name) || resources[i].plural_name.equals(name))
      return i;
  }
  
  if (settings.debugging)
    println("Couldn't find resource type '" + name + "'.");
  
  return -1;
}

class Resource
{
  boolean display;
  int val;
  String singular_name;
  String plural_name;
  int min_to_display;
  int alltime_amount;
  
  Resource(int _min_to_display, int _value, String _singular_name, String _plural_name, int _alltime_amount)
  {
    display = _value >= _min_to_display;
    val = _value;
    singular_name = _singular_name;
    plural_name = _plural_name;
    min_to_display = _min_to_display;
    alltime_amount = _alltime_amount;
  }
  
  String get_name()
  {
    return val > 1 ? plural_name : singular_name;
  }
  
  boolean visible()
  {
    display |= val >= min_to_display;
    return display;
  }
  
  int get_value()
  {
    return val;
  }
  
  void add_value(int amount)
  {
    if (amount > 0)
      alltime_amount += amount;
    
    val += amount;
  }
  
  int get_alltime_amount()
  {
    return alltime_amount;
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
  ResourceValue min_val;
  ResourceValue max_val;
  
  RandomResourceValue(int _min, int _max)
  {
    super(0);
    min_val = new ResourceValue(_min);
    max_val = new ResourceValue(_max);
  }
  
  int evaluate()
  {
    return (int)random(min_val.evaluate(), max_val.evaluate());
  }
  
  String to_string()
  {
    return "random(" + min_val.to_string() + "," + max_val.to_string() + ")";
  }
}

class ResourceExpression extends ResourceValue
{
  char op;
  ResourceValue left,
                right;
  
  ResourceExpression(String _input)
  {
    super(0);
    
    //find an operator
    
  }
  
  String to_string()
  {
    return left.to_string() + " " + op + " " + right.to_string();
  }
  
  int evaluate()
  {
    switch (op)
    {
      case '*': return left.evaluate() * right.evaluate();
      case '+': return left.evaluate() + right.evaluate();
      case '-': return left.evaluate() - right.evaluate();
      case '/': return left.evaluate() / right.evaluate();
      case '%': return left.evaluate() % right.evaluate();
    }
    
    println("Attempted to use unknown operator '" + op + "'. Returning -1;");
    return -1;
  }
}

class ResourceVariableValue extends ResourceValue
{
  int varindex;
  ResourceVariableValue(String _varname)
  {
    super(0);
    varindex = type_index_from_name(_varname);
  }
  
  String to_string()
  {
    return resources[varindex].plural_name;
  }
  
  int evaluate()
  {
    return resources[varindex].get_value();
  }
}