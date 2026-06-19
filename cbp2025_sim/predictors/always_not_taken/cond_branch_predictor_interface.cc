#include "lib/sim_common_structs.h"
#include "my_cond_branch_predictor.h"
#include <cassert>

//
// beginCondDirPredictor()
// Called before simulation starts
//
void beginCondDirPredictor()
{
    cond_predictor_impl.setup();
}

//
// notify_instr_fetch()
// Not used
//
void notify_instr_fetch(uint64_t seq_no, uint8_t piece,
                        uint64_t pc, const uint64_t fetch_cycle)
{
}

//
// get_cond_dir_prediction()
// Called only for conditional branches
//
bool get_cond_dir_prediction(uint64_t seq_no, uint8_t piece,
                             uint64_t pc, const uint64_t pred_cycle)
{
    return cond_predictor_impl.predict(seq_no, piece, pc);
}

//
// spec_update()
// Used for speculative history update
// Since your predictor has no global history,
// this is only needed for conditional branches.
//
void spec_update(uint64_t seq_no, uint8_t piece, uint64_t pc,
                 InstClass inst_class,
                 const bool resolve_dir,
                 const bool pred_dir,
                 const uint64_t next_pc)
{
    assert(is_br(inst_class));

    if(inst_class == InstClass::condBranchInstClass)
    {
        cond_predictor_impl.history_update(seq_no, piece, pc,
                                           resolve_dir, next_pc);
    }
}

//
// notify_instr_decode()
// Not used
//
void notify_instr_decode(uint64_t seq_no, uint8_t piece,
                         uint64_t pc, const DecodeInfo& _decode_info,
                         const uint64_t decode_cycle)
{
}

//
// notify_agen_complete()
// Not used
//
void notify_agen_complete(uint64_t seq_no, uint8_t piece,
                          uint64_t pc, const DecodeInfo& _decode_info,
                          const uint64_t mem_va,
                          const uint64_t mem_sz,
                          const uint64_t agen_cycle)
{
}

//
// notify_instr_execute_resolve()
// Used to train predictor on branch resolution
//
void notify_instr_execute_resolve(uint64_t seq_no, uint8_t piece,
                                  uint64_t pc,
                                  const bool pred_dir,
                                  const ExecuteInfo& _exec_info,
                                  const uint64_t execute_cycle)
{
    if(is_br(_exec_info.dec_info.insn_class))
    {
        if(is_cond_br(_exec_info.dec_info.insn_class))
        {
            const bool resolve_dir = _exec_info.taken.value();
            const uint64_t next_pc = _exec_info.next_pc;

            cond_predictor_impl.update(seq_no, piece, pc,
                                       resolve_dir, pred_dir, next_pc);
        }
        else
        {
            // Unconditional branches are always predicted taken
            assert(pred_dir);
        }
    }
}

//
// notify_instr_commit()
// Not used
//
void notify_instr_commit(uint64_t seq_no, uint8_t piece,
                         uint64_t pc,
                         const bool pred_dir,
                         const ExecuteInfo& _exec_info,
                         const uint64_t commit_cycle)
{
}

//
// endCondDirPredictor()
// Called at end of simulation
//
void endCondDirPredictor()
{
    cond_predictor_impl.terminate();
}
