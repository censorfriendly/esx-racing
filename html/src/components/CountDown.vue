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

<style scoped lang='scss'>
.countdown-container {
    position: absolute;
    // display: none;
    left: 50%;
    width: 30%;
    transform: translateX(-50%);
    top:5%;
    > div {
        display: flex;
        justify-content: space-between;
        align-items: stretch;
    }
    .signal {
        display: flex;
        width: 25px;
        height: 25px;
        border-radius: 50%;
        transition: all .25s ease-in-out;
        border: solid transparent 2px;
        background-color: transparent;
        opacity: 0;
        -webkit-box-shadow: 0px 4px 15px -4px #000000; 
        box-shadow: 0px 4px 15px -4px #000000;
        &.prep-1 {
            opacity: 1;
            border: solid #FF2211 2px;
            background-color: #FF2211;
        }
        &.prep-2,&.prep-4, &.prep-6, &.prep-7 {
            opacity: 0;
            border: solid #FFFFFF 2px;
            background-color: #FFFFFF;
        }
        &.prep-3 {
            opacity: 1;
            border: solid #F47C32 2px;
            background-color: #F47C32;
        }
        &.prep-5 {
            opacity: 1;
            border: solid #eea943 2px;
            background-color: #eea943;
        }
        &.start {
            opacity: 1;
            border: solid #22FF11 2px;
            background-color: #22FF11;
        }
    }
}
</style>
