#ifndef _PREDICTOR_H_
#define _PREDICTOR_H_

#include <cstdint>
#include <cassert>

class SampleCondPredictor
{
public:

    SampleCondPredictor() {}

    void setup() {}
    void terminate() {}

    // ========================
    // PREDICTION
    // ========================
    bool predict(uint64_t seq_no, uint8_t piece, uint64_t PC)
    {
        return false;   // Always Not Taken
    }

    void history_update(uint64_t seq_no, uint8_t piece, uint64_t PC,
                        bool taken, uint64_t nextPC)
    {
    }

    void update(uint64_t seq_no, uint8_t piece, uint64_t PC,
                bool resolveDir, bool predDir, uint64_t nextPC)
    {
        // No learning
    }
};

#endif

static SampleCondPredictor cond_predictor_impl;
