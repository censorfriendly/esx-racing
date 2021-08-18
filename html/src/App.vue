<template>
  <div id="app" :class="[activeRacingClass,raceAppClass]">
    <countDown />
    <activeRace />
    <raceApp />
  </div>
</template>

<script>
import activeRace from './components/activeRace';
import countDown from './components/CountDown';
import raceApp from './components/RaceApp';
import Nui from './utils/Nui';

export default {
  name: 'app',
  components: {
    activeRace,
    countDown,
    raceApp
  },
  data() {
    return {
      activeRacingClass : '',
      raceAppClass : ''
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
          this.activeRacingClass = 'racing-active ';
        }
        if(item.endRace || item.dnf) {
          setTimeout(this.closeAfterDelay, 5000)
        }
        if(item.raceApp) {
          this.raceAppClass ='racing-app'
          Nui.send('getCrypto',{})
        }
        if(item.closeApp) {
          this.raceAppClass = ''
        }
      },
      false,
    );
    this.keyListener = window.addEventListener(
      'keydown',
      e => {
        if (e.key == "Escape" || e.key == 'Delete' ) {
          Nui.send('closeApp',{})
        }
    });
  },
  methods: {
    closeAfterDelay: function() {
      this.activeRacingClass = '';
    }
  },
};
</script>

<style lang="scss">
@import "sass/globals"
</style>
