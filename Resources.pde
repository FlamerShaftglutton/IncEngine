
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
    display |= min_to_display >= 0 && val >= min_to_display;
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
    _input = _input.replaceAll("\\(([^,]+),([^,]+),([^,]+)\\)", "($1;$2;$3)");
    String[] chunks = trim(split(_input, ','));
    
    types = new int[chunks.length];
    values = new ResourceValue[chunks.length];
    
    for (int chunk = 0; chunk < chunks.length; chunk++)
    {
      String[] _tokens = tokenize_string(chunks[chunk],"()+-/*^%;", " \t\n\r");
      String resource_name = "";
      StringList operator_stack = new StringList();
      ArrayList<ResourceValue> operand_stack = new ArrayList<ResourceValue>();
      boolean expecting_operator = false;
      String ops = "()^~*/+-%";
      int[] precedence = {0,0,8,7,6,6,5,5,4};
      
      //parse as much as possible
      for (int i = 0; i < _tokens.length; i++)
      {
        String t = _tokens[i];
        
        //take care of unary minus
        if (t.equals("-") && !expecting_operator)
          t = "~";
        
        //if this is an operand...
        int index = ops.indexOf(t);
        if (index < 0 && !t.equals("random") && !t.equals("clamp") && !t.equals(";"))
        {
          //were we expecting an operand?
          if (!expecting_operator)
          {
            //determine what type of operand this is
            if (is_letter(t.charAt(0)))
            {
              //continue accruing chunks until we can't anymore
              String s = t;
              while (i + 1 < _tokens.length && is_letter(_tokens[i + 1].charAt(0)))
              {
                t += " " + _tokens[i + 1];
                i++;
              }
              
              //push this onto the operand stack
              operand_stack.add(new ResourceVariableValue(s));
            }
            else
            {
              operand_stack.add(new ResourceValue(parseInt(t)));
            }
            
            expecting_operator = true;
          }
          else
          {
            //we're done, the rest is the name of the resource
            while (i < _tokens.length)
            {
              resource_name += _tokens[i] + " ";
              i++;
            }
            resource_name = trim(resource_name);
            
            //now finish off the expression
            while (operator_stack.size() > 0)
            {
              int pindex = ops.indexOf(operator_stack.get(operator_stack.size() - 1));
              
              if (pindex < 0)
              {
                if (operator_stack.get(operator_stack.size() - 1).equals("random"))
                {
                  ResourceValue r = operand_stack.remove(operand_stack.size() - 1);
                  ResourceValue l = operand_stack.remove(operand_stack.size() - 1);
                  operand_stack.add(new RandomResourceValue(l,r));
                }
                else if (operator_stack.get(operator_stack.size() - 1).equals("clamp"))
                {
                  ResourceValue h = operand_stack.remove(operand_stack.size() - 1);
                  ResourceValue l = operand_stack.remove(operand_stack.size() - 1);
                  ResourceValue v = operand_stack.remove(operand_stack.size() - 1);
                  operand_stack.add(new ClampResourceValue(v,l,h));
                }
                else
                {
                  println("unknown function name '" + operator_stack.get(operator_stack.size() - 1) + "'. Exiting.");
                  return;
                }
              }
              else
              {
                //resolve the previous one first
                char pc = ops.charAt(pindex);
                ResourceValue r = pc == '~' ? null : operand_stack.remove(operand_stack.size() - 1);
                ResourceValue l = operand_stack.remove(operand_stack.size() - 1);
                operand_stack.add(new ResourceExpression(l,r, pc));
              }
              
              operator_stack.remove(operator_stack.size() - 1);
            }
          }
        }
        
        //if it's an operator...
        else
        {
          //check for random, unary minus, and left parens
          if (t.equals("random") || t.equals("clamp") || t.equals("~") || t.equals("(") || operator_stack.size() == 0)
          {
            operator_stack.append(t);
            expecting_operator = false;
          }
          else if (t.equals(")") || t.equals(";"))
          {
            while (operator_stack.size() > 0)
            {
              int pindex = ops.indexOf(operator_stack.get(operator_stack.size() - 1));
              
              if (pindex >= 0 && ops.charAt(pindex) == '(')
                break;
              
              if (pindex < 0)
              {
                if (operator_stack.get(operator_stack.size() - 1).equals("random"))
                {
                  ResourceValue r = operand_stack.remove(operand_stack.size() - 1);
                  ResourceValue l = operand_stack.remove(operand_stack.size() - 1);
                  operand_stack.add(new RandomResourceValue(l,r));
                }
                else if (operator_stack.get(operator_stack.size() - 1).equals("clamp"))
                {
                  ResourceValue h = operand_stack.remove(operand_stack.size() - 1);
                  ResourceValue l = operand_stack.remove(operand_stack.size() - 1);
                  ResourceValue v = operand_stack.remove(operand_stack.size() - 1);
                  operand_stack.add(new ClampResourceValue(v,l,h));
                }
                else
                {
                  println("unknown function name '" + operator_stack.get(operator_stack.size() - 1) + "'. Exiting.");
                  return;
                }
              }
              else// if (precedence[pindex] >= precedence[index])
              {
                //resolve the previous one first
                char pc = ops.charAt(pindex);
                ResourceValue r = pc == '~' ? null : operand_stack.remove(operand_stack.size() - 1);
                ResourceValue l = operand_stack.remove(operand_stack.size() - 1);
                operand_stack.add(new ResourceExpression(l,r, pc));
              }
              
              operator_stack.remove(operator_stack.size() - 1);
            }
            
            //now that we've processed everything, remove the left parenthesis (if need be)
            if (t.equals(")"))
            {
              operator_stack.remove(operator_stack.size() - 1);
              expecting_operator = true;
            }
            else
            {
              expecting_operator = false;
            }
          }
          else
          {
            //before adding this operator to the stack we need to see if it's lower precedence than the previous stack entry
            boolean continue_checking = true;
            while (continue_checking && operator_stack.size() > 0)
            {
              int pindex = ops.indexOf(operator_stack.get(operator_stack.size() - 1));
              
              if (pindex < 0)
              {
                if (operator_stack.get(operator_stack.size() - 1).equals("random"))
                {
                  ResourceValue r = operand_stack.remove(operand_stack.size() - 1);
                  ResourceValue l = operand_stack.remove(operand_stack.size() - 1);
                  operand_stack.add(new RandomResourceValue(l,r));
                }
                else if (operator_stack.get(operator_stack.size() - 1).equals("clamp"))
                {
                  ResourceValue h = operand_stack.remove(operand_stack.size() - 1);
                  ResourceValue l = operand_stack.remove(operand_stack.size() - 1);
                  ResourceValue v = operand_stack.remove(operand_stack.size() - 1);
                  operand_stack.add(new ClampResourceValue(v,l,h));
                }
                else
                {
                  println("unknown function name '" + operator_stack.get(operator_stack.size() - 1) + "'. Exiting.");
                  return;
                }
                
                operator_stack.remove(operator_stack.size() - 1);
              }
              else if (precedence[pindex] >= precedence[index])
              {
                //resolve the previous one first
                char pc = ops.charAt(pindex);
                ResourceValue r = pc == '~' ? null : operand_stack.remove(operand_stack.size() - 1);
                ResourceValue l = operand_stack.remove(operand_stack.size() - 1);
                operand_stack.add(new ResourceExpression(l,r, pc));
                
                operator_stack.remove(operator_stack.size() - 1);
              }
              else
              {
                continue_checking = false;
              }
            }
            
            //now add in this operator
            operator_stack.append(t);
            
            expecting_operator = false;
          }
        }
      }
      
      values[chunk] = operand_stack.get(0);
      types[chunk] = type_index_from_name(resource_name);
      
      if (types[chunk] < 0)
        println("Got '" + resource_name + "' from '" + chunks[chunk] + "'.");
    }
  }
  
  String to_string()
  {
    String[] derps = new String[types.length];

    for (int i = 0; i < types.length; i++)
    {
      derps[i] = "(" + values[i].to_string() + ") " + resources[types[i]].plural_name;
    }
    
    return join(derps, ", ");
  }
  
  String to_evaluated_string()
  {
    StringList derps = new StringList();
    
    for (int i = 0; i < types.length; i++)
    {
      if (types[i] == player_type_index)
        continue;
      
      int v = values[i].evaluate();
      derps.append(nf(v) + " " + (v == 1 ? resources[types[i]].singular_name : resources[types[i]].plural_name));
    }
    
    return join(derps.array(), ", ");
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
  
  RandomResourceValue(ResourceValue _min_val, ResourceValue _max_val)
  {
    super(0);
    min_val = _min_val;
    max_val = _max_val;
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

class ClampResourceValue extends ResourceValue
{
  ResourceValue value;
  ResourceValue lowest_val;
  ResourceValue highest_val;
  
  ClampResourceValue(ResourceValue _value, int _lowest, int _highest)
  {
    super(0);
    value=_value;
    lowest_val = new ResourceValue(_lowest);
    highest_val = new ResourceValue(_highest);
  }
  
  ClampResourceValue(ResourceValue _value, ResourceValue _lowest, ResourceValue _highest)
  {
    super(0);
    value = _value;
    lowest_val = _lowest;
    highest_val = _highest;
  }
  
  int evaluate()
  {
    return constrain(value.evaluate(), lowest_val.evaluate(), highest_val.evaluate());
  }
  
  String to_string()
  {
    return "clamp(" + value.to_string() + ", " + lowest_val.to_string() + ", " + highest_val.to_string() + ")";
  }
}

class ResourceExpression extends ResourceValue
{
  char op;
  ResourceValue left,
                right;
  
  ResourceExpression(ResourceValue _left, ResourceValue _right, char _op)
  {
    super(0);
    
    //find an operator
    left = _left;
    right = _right;
    op = _op;
  }
  
  String to_string()
  {
    if (op == '~')
      return "-" + left.to_string();
    
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
      case '^': return int(pow(left.evaluate(), right.evaluate()));
      case '~': return -left.evaluate();
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

String[] tokenize_string(String _input, String _split_keep, String _split_consume)
{
  StringList sl = new StringList();
  String cs = "";
  
  for (int i = 0; i < _input.length(); i++)
  {
    char c = _input.charAt(i);
    int ki = _split_keep.indexOf(c);
    int ci = _split_consume.indexOf(c);
    
    if (ki >= 0 || ci >= 0)
    {
      if (cs.length() > 0)
        sl.append(cs);
      
      if (ki >= 0)
        sl.append("" + c);
      
      cs = "";
    }
    else
      cs += c;
  }
  
  if (cs.length() > 0)
    sl.append(cs);
  
  return sl.array();
}

boolean is_letter(char _c)
{
  return (_c >= 'a' && _c <= 'z') || (_c >= 'A' && _c <= 'Z');
}