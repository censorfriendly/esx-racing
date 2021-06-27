export default {
    timeConvert(timestamp) {
        if(timestamp == 'DNF') {
          return timestamp;
        }
        var finishedTime = new Date(timestamp)
        , hour = finishedTime.getUTCHours()
        , min = finishedTime.getUTCMinutes()
        , sec = finishedTime.getUTCSeconds()
        , ms = finishedTime.getUTCMilliseconds();
        var time =
          zeroPrefix(hour, 2) + ":" + 
          zeroPrefix(min, 2) + ":" + 
          zeroPrefix(sec, 2) + "." + 
          zeroPrefix(ms, 3);
          return time;
      },
      zeroPrefix(num, digit) {
          var zero = '';
          for(var i = 0; i < digit; i++) {
              zero += '0';
          }
          return (zero + num).slice(-digit);
      },
  };
  