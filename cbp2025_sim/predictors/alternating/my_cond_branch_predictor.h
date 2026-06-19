#ifndef _PREDICTOR_H_
#define _PREDICTOR_H_

#include <cstdint>
#include <cassert>

class SampleCondPredictor
{
    static constexpr int NUM_SETS = 1024;
    static constexpr int WAYS = 2;
    static constexpr int INDEX_BITS = 10;

    struct BTBEntry {
        bool valid;
        uint32_t tag;
        bool state;   // 1-bit alternating state
                      // 0 = Not Taken
                      // 1 = Taken
    };

    BTBEntry table[NUM_SETS][WAYS];
    bool lru[NUM_SETS];

public:

    SampleCondPredictor() {}

    void setup()
    {
        for(int i = 0; i < NUM_SETS; i++)
        {
            lru[i] = 0;
            for(int w = 0; w < WAYS; w++)
            {
                table[i][w].valid = false;
                table[i][w].state = false;  // start at Not Taken
            }
        }
    }

    void terminate() {}

    // ========================
    // PREDICTION
    // ========================
    bool predict(uint64_t seq_no, uint8_t piece, uint64_t PC)
    {
        uint32_t index = (PC >> 2) & (NUM_SETS - 1);
        uint32_t tag   = PC >> (2 + INDEX_BITS);

        BTBEntry &way0 = table[index][0];
        BTBEntry &way1 = table[index][1];

        bool hit0 = way0.valid && (way0.tag == tag);
        bool hit1 = way1.valid && (way1.tag == tag);

        if(hit0)
            return way0.state;

        if(hit1)
            return way1.state;

        return false;  // Miss → predict Not Taken
    }

    void history_update(uint64_t seq_no, uint8_t piece, uint64_t PC,
                        bool taken, uint64_t nextPC)
    {
        // No global history
    }

    // ========================
    // RESOLVE UPDATE
    // ========================
    void update(uint64_t seq_no, uint8_t piece, uint64_t PC,
                bool resolveDir, bool predDir, uint64_t nextPC)
    {
        uint32_t index = (PC >> 2) & (NUM_SETS - 1);
        uint32_t tag   = PC >> (2 + INDEX_BITS);

        BTBEntry &way0 = table[index][0];
        BTBEntry &way1 = table[index][1];

        bool hit0 = way0.valid && (way0.tag == tag);
        bool hit1 = way1.valid && (way1.tag == tag);

        BTBEntry *entry = nullptr;

        if(hit0)
        {
            entry = &way0;
            lru[index] = 1;
        }
        else if(hit1)
        {
            entry = &way1;
            lru[index] = 0;
        }
        else
        {
            // Replacement
            int victim = lru[index] ? 1 : 0;
            entry = &table[index][victim];

            entry->valid = true;
            entry->tag = tag;
            entry->state = 0;  // initialize to NT

            lru[index] = victim ? 0 : 1;
        }

        // === Alternating behavior ===
        // Flip state every update
        entry->state = !entry->state;
    }
};

#endif

static SampleCondPredictor cond_predictor_impl;
