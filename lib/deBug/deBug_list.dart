class DeBugMessage {
  static List<String> mistakes = [];

  static void addMistake(String mistake) {

    //添加时间前缀
    mistake = DateTime.now().toString()+'\n'+ mistake;
    mistakes.add(mistake);
  }

  static void printMistake() {
    mistakes.forEach((element) {
      print(element);
    });
  }
  
  static void clearMistake() {
    mistakes.clear();
  }
}