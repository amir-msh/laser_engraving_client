int setBitInByte(int byte, int bitIndex, bool value) {
  if (value) return byte | (1 << bitIndex);
  return byte & (~(1 << bitIndex));
}
