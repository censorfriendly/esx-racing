<template>
  <div class="racingStats">
        <table border-spacing="none">
            <tr>
                <td>
                    <h3>Pos: {{ pos }} / {{totalPos}}</h3>
                </td>
                <td>
                    <h3>Lap: {{ lap }} / {{totalLaps}}</h3>
                </td>
            </tr>
            <tr>
                <td>
                    <h3>Checkpoint:</h3>
                </td>
                <td>
                    <h3> {{ checkPoint }} / {{totalCheckpoint}}</h3>
                </td>
            </tr>
            <tr>
                <td>
                    <h3>Time:</h3>
                </td>
                <td>
                    <h3> {{ time }}</h3>
                </td>
            </tr>
            <tr>
                <td>
                    <h3>Lap Time:</h3>
                </td>
                <td>
                    <h3> {{ lapTime }}</h3>
                </td>
            </tr>
            <tr>
                <td>
                    <h3>Best Lap Time:</h3>
                </td>
                <td>
                    <div v-if="lap == 1">
                        <h3>{{ time }}</h3>
                    </div>
                    <div v-else >
                        <h3>{{ bestLap }}</h3>
                    </div>
                </td>
            </tr>
        </table>
    
  </div>
</template>

<script>
import Nui from '../utils/Nui';
export default {
  name: 'active-race',
  props: {
    name: {
        
    },
  },
    data() {
        return {
            time: '00:00:00.000',
            lapTime: '00:00:00.000',
            bestLap: '00:00:00.000',
            timeBegan: null,
            timeStopped: null,
            stoppedDuration: 0,
            started: null,
            running: false,
            pos: 1,
            totalPos: 1,
            checkPoint: 0,
            totalCheckpoint: 0,
            lap: 1,
            totalLaps: 0,
            lastLapTime: 0,
            bestLapTime: 0,
        }
    },
    methods: {
        start: function() {
            if(this.running) return;
            
            if (this.timeBegan === null) {
                this.reset();
                this.timeBegan = new Date();
                this.lastLapTime = this.timeBegan;
            }

            this.started = setInterval(this.clockRunning, 10);	
            this.running = true;
        },
        stop: function() {
            this.running = false;
            this.timeStopped = new Date();
            clearInterval(this.started);
        },
        reset: function() {
            
            this.running = false;
            clearInterval(this.started);
            this.timeBegan = null;
            this.timeStopped = null;
            this.time = "00:00:00.000";
            this.lapTime = "00:00:00.000";
            this.bestLap = "00:00:00.000";
            this.bestLapTime = 0;
            this.lastLapTime = 0;
            this.started = null;

        },
        clockRunning: function() {
            var currentTime = new Date()
            , timeElapsed = new Date(currentTime - this.timeBegan)
            , hour = timeElapsed.getUTCHours()
            , min = timeElapsed.getUTCMinutes()
            , sec = timeElapsed.getUTCSeconds()
            , ms = timeElapsed.getUTCMilliseconds();
            this.time = 
                this.zeroPrefix(hour, 2) + ":" + 
                this.zeroPrefix(min, 2) + ":" + 
                this.zeroPrefix(sec, 2) + "." + 
                this.zeroPrefix(ms, 3);

            timeElapsed = new Date(currentTime - this.lastLapTime)
            , hour = timeElapsed.getUTCHours()
            , min = timeElapsed.getUTCMinutes()
            , sec = timeElapsed.getUTCSeconds()
            , ms = timeElapsed.getUTCMilliseconds();
            this.lapTime = 
                this.zeroPrefix(hour, 2) + ":" + 
                this.zeroPrefix(min, 2) + ":" + 
                this.zeroPrefix(sec, 2) + "." + 
                this.zeroPrefix(ms, 3);
        },
        zeroPrefix: function(num, digit) {
            var zero = '';
            for(var i = 0; i < digit; i++) {
                zero += '0';
            }
            return (zero + num).slice(-digit);
        },
        checkPointEvent: function() {
            this.checkPoint++;
        },
        lapEvent: function() {
            this.checkPoint = 1;
            if (this.lap < this.totalLaps) {
                this.lap++;
            }
            this.bestTime();
            
        },
        bestTime: function() {
            var currentTime = new Date()
            , timeElapsed = new Date(currentTime -  this.lastLapTime)
            , hour = timeElapsed.getUTCHours()
            , min = timeElapsed.getUTCMinutes()
            , sec = timeElapsed.getUTCSeconds()
            , ms = timeElapsed.getUTCMilliseconds();
            var time =
                this.zeroPrefix(hour, 2) + ":" + 
                this.zeroPrefix(min, 2) + ":" + 
                this.zeroPrefix(sec, 2) + "." + 
                this.zeroPrefix(ms, 3);
            this.lastLapTime = currentTime;
            console.log("looking at best lap time");
            console.log(this.bestLapTime);
            console.log(timeElapsed);
            if(!this.bestLapTime || timeElapsed < this.bestLapTime) {
                this.bestLap = time;
                this.bestLapTime = timeElapsed;
                // var raceId = this.$store.state.raceApp.race_id;
                // Nui.send('setBestLap',
                // {
                //     bestLap:timeElapsed,
                //     raceId:raceId
                // });
            }
        }
    },
    mounted() {
        this.listener = window.addEventListener(
        'message',
        event => {
            const item = event.data || event.detail;
            if (item.startrace) {  
                this.reset()
                this.start()
            }
            if (item.checkPoint) {
                this.checkPointEvent()
            }
            if (item.lapEvent) {  
                this.lapEvent()
            }
            if(item.endRace) {
                if(this.bestLapTime == 0)
                    this.bestTime()
                // this.bestTime();
                var currentTime = new Date();
                var timeElapsed = new Date(currentTime - this.timeBegan)
                Nui.send('raceStats',
                {
                    raceId: this.$store.state.raceApp.race_id,
                    bestLap: this.bestLapTime,
                    trackTime: timeElapsed
                });
                this.stop();
            }
            if(item.positionUpdate) {
                this.pos = item.position;
            }
            if(item.setRaceConfig) {
                this.pos = 1;
                this.checkPoint = 0;
                this.lap = 1;
                this.totalLaps = item.raceConfig.laps;
                this.totalCheckpoint = item.raceConfig.totalChecks;
                this.totalPos = item.raceConfig.racerCount;
            }
            if(item.dnf) {
                this.stop();
                this.reset()
            }
        },
        false,
        );
    },
};
</script>

<style lang="scss" scoped>
.racingStats {
    display: none;
    position: absolute;
    bottom:15%;
    right:5%;
    // width: 15%;
    height: auto;
    background: rgba(#000000, 0.2);
    color:#FFFFFF;
    border-radius: 25px;
    h3 {
        margin: 0;
        padding: 0;
        font-weight: bold;
        font-size: 1.5rem;
        line-height: 1.5rem;
    }
}

</style>
