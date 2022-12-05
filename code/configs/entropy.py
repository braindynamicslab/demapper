import numpy as np
import math

ps = [0.1, 0.25, 0.25, 0.4]
assert sum(ps) == 1.0

E_A = sum([-p * np.log2(p) for p in ps])
