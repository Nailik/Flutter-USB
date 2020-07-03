class Command {
  int outDataLength;
  List<int> inData;

  Command(this.inData, {this.outDataLength = 1024});
}
