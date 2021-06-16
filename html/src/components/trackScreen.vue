<template>
  <div class="trackScreen">
      <h3>Build track screen template</h3>
      <div v-for="(track,index) in trackObject" :key="index">
          <h4 @click="setRace(index)" v-html="track.Config.Name"/>
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

  },
  data() {
    return {
      trackObject : {},
      selectedRace : 0,
      formActive : false,
      config: {
        laps: 1,
        race_id: 1
      }
    };
  },
  mounted() {
    Nui.send('getTracks',{})
    this.listener = window.addEventListener(
      'message',
      event => {
        const item = event.data || event.detail;
        if (item.trackListEvent) {
          this.trackObject = item.tracks
        }
      },
      false,
    );
  },
  methods: {
      setRace: function(index) {
        this.selectedRace = index;
        this.formActive = 1;
      },
      createRace: function() {
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
