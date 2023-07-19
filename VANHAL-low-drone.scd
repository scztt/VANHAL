

Require("teckDelay");

(
Pdef(\notes, PS(Pbind(
    \scale, Scale.hexSus,
    \octave, 2 + [0, 2, 3, 0],
    \degree, 0 + Ptuple([
        Pseq([0, 1], inf).durStep(24),
        3,
        Pseq([-1, -2], inf).durStep(24),
        0
    ]),
    \degree, Pkey(\degree) + Pseq([0, -2], inf).durStep(48),
)));

Pdef(\van, Pbind(
    // \grainSampler_2ch,
    \instrument, \grainSampler_2ch,
    \buf, SAMP("vanhalen/mixdown.wav", channels:1)[0],    
    
    \dur, 24,
    \legato, 0.6,
    \trig, 0,
    
    \amp, 6.dbamp * [0, 6, 6, 0].dbamp,
    \pan, 0.5 * [-1, 1],
    
    \pos, Pmod(
        {
            var lfoRate = \lfoRate.kr(1);
            lfoRate = lfoRate + [0, 1/16].resamp1(4);
            
            LFTri.ar(1/256).range(
                // "5:48".asSecs,
                // "5:52".asSecs
                "6:03".asSecs,
                "6:12".asSecs
            )
            + (
                \lfoScale.kr(1) 
                    * SinOsc.ar(lfoRate).range(
                        -1, 
                        1
                    )
            )
        }, 
        \lfoScale, 0.02,
        \lfoRate, 1/32
    ).expand,
    
    \trigRate, { ~detunedFreq.value * 1 },
    \trigRateV, 0.001,
    \density, 200,
    
    \ampEnv, `Env([0, 1, 0], [6, 8], \sine, releaseNode:1),
    
    \grainRate, { (~detunedFreq.value.cpsmidi - 42).midiratio.postln },
    
    \filtLo, 20,
    \filtHi, Pmod({
        SinOsc.ar(1/256, 0 + [0, 0.2].resamp1(4) - (pi/2)).exprange(100, 1300)
    }),
    \finish, {
        ~grainRate = ~grainRate.value;
        ~trigRate = ~trigRate.value;
    }
) <> Pdef(\notes));

Pdef(\delay, Pmono(
    \grainDelay2,
    \parentType, \grainDelay2,
    
    \finish, {
        ~in = ~in.value.postln;
        ~grainRate = ~grainRate.value;
        ~trigRate = ~trigRate.value;
        ~grainRate = ~grainRate.value;
        ~delayRound = ~delayRound.value;
    },
    
    \octave, Pkey(\octave) + 1,
    
    \delay, Pmod({
        var flux = LFDNoise3.ar(1/14).exprange(
            1/8,
            2
        ).reciprocal;
        
        4.collect {
            DelayC.ar(flux, 1, LFDNoise3.kr(1/24).range(0, 1/32))
        }
    }).expand,
    \delayV, Pmod({
        1 / SinOsc.ar(1/124).exprange(10, 200)
    }),
    
    \delayRound, { ~detunedFreq.value.reciprocal },
    \delayRoundLag, 8,
    \delayRoundOffset, Pmod(
        {
            var roundOff = \roundOff.kr([1, 1, 1, 1]).lag(8);
            0.6 * roundOff * LFDNoise3.ar(1/14).lag(0.1 * [0.1, 1.0, 0.4, 0.0].scramble)
        }, 
        \roundOff, Pkey(\delayRound)
    ).expand,
    
    \trig, 0,
    
    \trigRate, 60 * 1,
    
    \density, 90,
    
    \grainRate, Pmod({
        4.collect {
            var trig = Dust.ar(0.05);
            (
                Env.sine(4).ar(gate:trig)
                    * LFDNoise3.ar(1/4).range(-0.5, 0.0)
            ).midiratio
        }
    }).expand,
    
    \feedAmp, -38.dbamp,
    
    \feedDist, 0.3,
    \filtLo, 60,
    \filtHi, Pexprand(200, 5900).durStep(12),
    \filtLag, 24,
    
    \pan, [-0.8, 0.8].resamp1(4),
    \panV, 0.2,
    
    \amp, -12.dbamp,
    \dryAmp, -14.dbamp
) <> Pdef(\notes));

Pdef(\teckDelay, Pmono(
    \teckDelay,
    \amp, -16.dbamp,
    \inAmp, -16.dbamp,
    \crushAmp, 0.dbamp,
    \dryAmp, 0.dbamp,
    \wetAmp, 10.dbamp,
    \inEnv, 0
));

Pdef(\vanCompress,
    Pdef(\compressor)
).set(
    \c, ~vanCompress = ~vanCompress ?? {
        ControlValueEnvir(BusControlValue)
});

Pdef(\player, Pio(Ppar(
    Pio.make({
        // ~van.out = 0;
        ~van.out = Pout(\delay, 2);
        ~delay.in = Pin(\delay, 2);
        ~teckDelay.in = ~delay;
        ~vanCompress.in = ~teckDelay;
        ~vanCompress.out = 0;
    }, Pdef.all)
))).play
)


~vanCompress.gui
            
                
