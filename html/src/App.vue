<template>
  <div id="app" :class="dynClass">
    <countDown />
    <activeRace />
    <raceApp />
  </div>
</template>

<script>
import activeRace from './components/activeRace';
import countDown from './components/CountDown';
import raceApp from './components/RaceApp';
// import Nui from './utils/Nui';

export default {
  name: 'app',
  components: {
    activeRace,
    countDown,
    raceApp
  },
  data() {
    return {
      dynClass : ''
    };
  },
  destroyed() {
    window.removeEventListener('message', this.listener);
  },
  mounted() {
    this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.openRacing) {  
          this.dynClass = 'racing-active ';
        }
        if(item.endRace) {
          setTimeout(this.closeAfterDelay, 5000)
        }
        if(item.raceApp) {
          this.dynClass ='racing-app'
        }
      },
      false,
    );
  },
  methods: {
    closeAfterDelay: function() {
      this.dynClass = '';
    }
  },
};
</script>

<style lang="scss">
/* Want nice animations? Check out https://github.com/asika32764/vue2-animate */
/* @import 'https://unpkg.com/vue2-animate/dist/vue2-animate.min.css'; */
@import url('https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@0,400;0,700;1,400&display=swap');
#app {
  // display:none;
  font-family: 'Open Sans', sans-serif;
  background: transparent;
  &.racing-active{
    display: block;
    .racingStats {
      display: block;
    }
  }
  &.racing-app {
    display: block;
    .racing-app {
      display: block;
    }
  }

  
  table {
      margin: 0;
      padding: 0;
      border: 0;
      outline: 0;
      font-size: 100%;
      vertical-align: baseline;
      background: transparent;
      td {
          padding:10px;
      }
  }
  .grid {
    display: flex;
    justify-content: space-between;

    &.center {
      text-align: center;
    }
  }
  .grid.third {
    > div {
      flex-basis: 33.33%;
    }
  }
}
</style>
