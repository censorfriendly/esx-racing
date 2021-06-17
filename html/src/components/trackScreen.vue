<template>
  <div class="trackScreen">
      <h3>Build track screen template</h3>
      <div v-for="(track,index) in trackObject" :key="index">
          <div class="grid third center">
            <div><h4 v-html="track.Config.Name"/></div>
            <div><button @click="setRace(index)" class="">Create Race</button></div>
            <div><button class="">View Race</button></div>
          </div>
      </div>
      <div class="form" :class="{active:formActive}">
          <label>No. of Laps</label>
          <input v-model="config.laps">
          <input type="hidden" v-model="config.race_id"/>
          <button @click="createRace">Setup Race</button>
          <button @click="clearRace">Cancel Setup</button>
      </div>
  </div>
</template>

<script>
import Nui from '../utils/Nui';
export default {
  name: 'track-screen',
  props: {
    trackList: []
  },
  data() {
    return {
      trackObject : this.trackList,
      selectedRace : 0,
      formActive : false,
      config: {
        laps: 1
      }
    };
  },
  mounted() {

  },
  methods: {
      setRace: function(index) {
        this.selectedRace = index;
        this.formActive = 1;
      },
      createRace: function() {
        Nui.send('createRace',{
          raceId: this.selectedRace + 1,
          laps: this.config.laps
        })
        this.formActive = 0;
      },
      clearRace: function() {
        this.formActive = 0;
      }
  }
};
</script>

<style lang="scss">
.trackScreen {
  position: relative;
  overflow: hidden;
}
.form {
  position: absolute;
  width:80%;
  left:10%;
  top:-100%;
  transition: .25s ease-in;
  background-color: white;
  padding:25px;
  &.active {
    top:0px;
  }
}

</style>
