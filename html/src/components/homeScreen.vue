<template>
  <div>
    <h2>Races This Session</h2>
    <div v-if="archiveObject" class="raceStats">
      <div v-for="index in archiveObject.length" :key="index" class="togglable">
        <div class="row" @click="toggleView(index)">
          <h4 v-html="archiveObject[archiveObject.length - index].name" class="col-md-6" />
          <h4 v-html="archiveObject[archiveObject.length - index].title" class="col-md-6" />
        </div>
        <div class="expand-height" :class="{active:viewingRace == index}">
          <div class="row">
            <h5 class="col-md" >Racer:</h5>
            <h5 class="col-md" >Total Time:</h5>
          </div>
          <div v-for="(racer,rindex) in archivedRacers[archiveObject.length - index]" :key="rindex" class="row">
            <h5 v-html="racer.player_name" class="col-md" />
            <h5 v-html="timeConvert(racer.total_time)" class="col-md" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'home-screen',
  props: {
    
  },
  data() {
    return {
      viewingRace: -1
    }
  },
  methods: {
    getLastRace: function() {

    },
    toggleView: function(i) {
      if (this.viewingRace == i) {
        this.viewingRace = -1;
      } else 
      this.viewingRace = i;
    },
    timeConvert: function(timestamp) {
      if(timestamp == 'DNF') {
        return timestamp;
      }
      var finishedTime = new Date(timestamp)
      , hour = finishedTime.getUTCHours()
      , min = finishedTime.getUTCMinutes()
      , sec = finishedTime.getUTCSeconds()
      , ms = finishedTime.getUTCMilliseconds();
      var time =
        this.zeroPrefix(hour, 2) + ":" + 
        this.zeroPrefix(min, 2) + ":" + 
        this.zeroPrefix(sec, 2) + "." + 
        this.zeroPrefix(ms, 3);
        return time;
    },
    zeroPrefix: function(num, digit) {
        var zero = '';
        for(var i = 0; i < digit; i++) {
            zero += '0';
        }
        return (zero + num).slice(-digit);
    },
  },
  mounted() {
      this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.raceData) {
          this.$store.state.home.finishedRaces = item.raceInfo;
          this.$store.state.home.finishedRacesRacers = item.racers;
        }
      },
      false,
    );
  },
  computed: {
    archiveObject: function() {
      return  this.$store.state.home.finishedRaces;
    },
    archivedRacers: function() {
      return this.$store.state.home.finishedRacesRacers;
    }
  }
};
</script>

<style scoped></style>
