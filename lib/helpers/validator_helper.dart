
class ValidatorHelper{
  required(value){
    if(value == null || value.isEmpty){
      return "This field is required";
    }
    return null;
  }
  validPasswordFormat(String value){
    if(value == "" || value.isEmpty){
      return "This field is required";
    } else if(value.length < 6){
      return "Be at least 6 characters long";
    }
    return null;
  }
  validEmailAddressFormat(String value){
    RegExp format = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    if(value == "" || value.isEmpty){
      return "This field is required";
    }else if(!format.hasMatch(value)){
      return "Invalid email format";
    }
    return null;
  }

  validConfirmPasswordFormat(String value, String compareValue){
    if(value != compareValue){
      return "The password is not match";
    }
    return null;
  }

}
