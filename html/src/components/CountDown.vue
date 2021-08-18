<template>
  <div class="countdown-container">
      <div>
          <div :class="dynClass" class="signal signal-1"></div>
          <div :class="dynClass" class="signal signal-2"></div>
          <div :class="dynClass" class="signal signal-3"></div>
          <div :class="dynClass" class="signal signal-4"></div>
      </div>
  </div>
</template>

<script>
export default {
  name: 'count-down',
  props: {
    name: {

    },
  },
  data() {
    return {
      lightKey:1,
      startSignal: false,
      dynClass: ''
    }
  },
  mounted() {
    this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.countdown) {  
            this.lightKey = 1;
            this.dynClass = '';
            this.startCountDown();
        }
      },
      false,
    );
  },
  methods: {
      startCountDown: function() {
          this.dynClass = 'prep-' + this.lightKey;
          this.lightKey++;
          if(this.lightKey <= 6) {
            setTimeout(this.startCountDown,500)
          }
          else {
            setTimeout(this.startRace,500)
          }
      },
      triggerCountdown: function() {
            this.lightKey = 1;
            this.dynClass = '';
            this.startCountDown();
      },
      startRace: function() {
          this.dynClass = 'start';

          setTimeout(this.clear,1000);
      },
      clear:function() {
        this.lightKey = 1;
        this.dynClass = '';
      }
  }
};
</script>

<style lang='scss'>
</style>
