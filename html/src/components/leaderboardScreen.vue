<template>
 <div>
    <div v-for="(track,index) in trackObject" :key="index">
        <div class="row" :class="{evenRow: index % 2 == 0}">
          <div @click="getRaceData(index)" class="col-md-12"><h4 v-html="track.Config.Name"/></div>
          <div class="expand-height col-md-12" v-if="activeIndex == index" :class="{active:activeIndex == index}">
            <div v-if="leaderboardObject.length > 0">
              <div class="row col-md-12" v-for="(stat,sindex) in leaderboardObject" :key="sindex">
              <h5 class="col-md-6" >Racer: <span v-html="stat.player_name"></h5>
              <h5 class="col-md-6" >Best Lap: <span v-html="timeConvert(stat.best_lap)"></h5>
              </div>
            </div>
            <div v-else>
              <h5 class="col-md-6" >No Lap Records been set</h5>
            </div>
          </div>
        </div>
    </div>
  </div>
</template>

<script>
import Nui from '../utils/Nui';
export default {
  name: 'leaderboard-screen',
  props: {

  },
  data() {
    return {
      activeIndex: -1
    };
  },
  mounted() {
    this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.leaderboardEvent) {
           this.$store.state.leaderboard = item.list;
        }
      },
      false,
    );
  },
  computed: {
    leaderboardObject: function() {
      return this.$store.state.leaderboard;
    },
    trackObject: function() {
      return this.$store.state.trackList;
    }
  },
  methods: {
    getRaceData: function(rindex) {
      if(this.activeIndex != rindex) {
        this.activeIndex = rindex;
        this.$store.state.leaderboard = {};
        Nui.send('getLeaderboards',{
          race_id: this.activeIndex + 1
        })
      }
      else {
        this.activeIndex = -1;
        this.$store.state.leaderboard = {};
      }
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
};
</script>

<style lang="scss">
</style>
