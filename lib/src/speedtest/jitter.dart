class Jitter {
  /**
   * Compute the jitter from a list of latencies
   * RFC 1889 (https://www.ietf.org/rfc/rfc1889.txt):
   * J=J+(|D(i-1,i)|-J)/16
   */
  static double compute(List<double> latencies) {
    int index = 0;
    double jitter = latencies.fold(0, (jitter, latency) {
      final currentIndex = index++;
      if (currentIndex == 0) {
        return 0;
      }

      return (jitter + ((latencies[currentIndex - 1] - latency).abs() - jitter) / 16.0);
    });
    return jitter;
  }
}
