# Macaque Categorical Decision Decoding (MATLAB)

This repository provides a small, fully reproducible MATLAB pipeline for
categorical decision-making with simulated macaque single-/multi-unit
spiking data.

The code mimics a typical workflow in decision-neuroscience labs:

1. **Simulate experiment structure**
   - Two visual categories (Cat1 vs Cat2)
   - Repetition number (1–4)
   - Response context (Go vs No-Go)
   - Multiple units with heterogeneous tuning

2. **Build analysis-ready datasets**
   - Event-aligned, binned spike counts
   - Long-form (`tidy`) tables with trial × unit × time bin
   - Condition labels (category, repetition, go/no-go)

3. **Quantify category discriminability over time**
   - Per-unit firing rate time courses
   - Time-resolved AUROC for Cat1 vs Cat2
   - Population summaries across units

4. **Decode category from population activity**
   - Pseudo-population feature matrices
   - Cross-validated logistic-regression decoders
   - Optional filtering by repetition / response context

All data here are **simulated**; no experimental data from any lab are included.