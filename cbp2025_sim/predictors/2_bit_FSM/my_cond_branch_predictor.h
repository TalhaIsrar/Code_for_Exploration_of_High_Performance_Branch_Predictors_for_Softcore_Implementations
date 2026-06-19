#ifndef _PREDICTOR_H_
#define _PREDICTOR_H_

#include <cstdint>
#include <cassert>

class SampleCondPredictor
{
    static constexpr int NUM_SETS = 1024;
    static constexpr int WAYS = 2;
    static constexpr int INDEX_BITS = 10; // log2(NUM_SETS)

    struct BTBEntry {
        bool valid;
        uint32_t tag;
        uint8_t state;   // 2-bit saturating counter (0-3)
    };

    BTBEntry table[NUM_SETS][WAYS];
    bool lru[NUM_SETS];   // 1-bit LRU per set

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
                table[i][w].state = 0;   // Strongly Not Taken
            }
        }
    }

    void terminate() {}

    // ========================
    // PREDICTION
    // ========================
    bool predict(uint64_t seq_no, uint8_t piece, uint64_t PC)
    {
        uint32_t index = (PC >> 2) & (NUM_SETS - 1);   // index = PC[11:2] as PC[1:0] are for byte offset (PC[31:2] & 10'(1))
        uint32_t tag   = PC >> (2 + INDEX_BITS);       // tag = PC[31:12] (PC >> 12)

        BTBEntry &way0 = table[index][0];
        BTBEntry &way1 = table[index][1];

        bool hit0 = way0.valid && (way0.tag == tag);
        bool hit1 = way1.valid && (way1.tag == tag);

        if(hit0)
            return way0.state >> 1;  // MSB = prediction

        if(hit1)
            return way1.state >> 1;

        return false;  // Miss → predict Not Taken
    }

    // ========================
    // HISTORY UPDATE
    // ========================
    // Not needed since no global history used
    void history_update(uint64_t seq_no, uint8_t piece, uint64_t PC,
                        bool taken, uint64_t nextPC)
    {
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
            lru[index] = 1;  // mark way1 as LRU
        }
        else if(hit1)
        {
            entry = &way1;
            lru[index] = 0;  // mark way0 as LRU
        }
        else
        {
            // Replacement
            int victim = lru[index] ? 1 : 0;
            entry = &table[index][victim];

            entry->valid = true;
            entry->tag = tag;
            entry->state = 0;  // initialize to Strongly Not Taken

            lru[index] = victim ? 0 : 1;
        }

        // 2-bit saturating counter update
        if(resolveDir)   // branch was taken
        {
            if(entry->state < 3) entry->state++;        // move to strong taken
        }
        else         // branch was not taken
        {
            if(entry->state > 0) entry->state--;        // move to strong not taken
        }
    }
};

#endif

static SampleCondPredictor cond_predictor_impl;
