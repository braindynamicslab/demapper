import fire
import os
import matplotlib.pyplot as plt
import numpy as np
from tqdm import tqdm
import math
from PIL import Image


def plot_image(img_path, ax):
    im = Image.open(img_path)
    img = np.array(im)
    ax.imshow(img)
    del img
    del im
    return ax


def process_mapper(sbjs, mapper, main_path, res_path, fname):
    savepath = os.path.join(res_path, '{}-{}'.format(mapper, fname))
    if os.path.isfile(savepath):
      return

    ncols = 5
    nrows = math.ceil(len(sbjs) / ncols)
    fsize = 20 

    fig, axr = plt.subplots(nrows=nrows, ncols=ncols, figsize=(fsize * (ncols/nrows)*1.1,fsize))

    index = 0
    for r,axc in enumerate(axr):
        for c,ax in enumerate(axc):
            # Disable ax defaults
            ax.tick_params(left=False, bottom=False, labelleft=False, labelbottom=False)
            ax.spines['top'].set_visible(False)
            ax.spines['right'].set_visible(False)
            ax.spines['bottom'].set_visible(False)
            ax.spines['left'].set_visible(False)
            ax.grid(False)

            # get sbj and img_path and plot
            if index >= len(sbjs):
                continue
            sbj = sbjs[index]
            img_path = os.path.join(main_path, sbj, mapper, fname)

            plot_image(img_path, ax)
            ax.set_title(sbj)
            index += 1

    plt.suptitle(mapper)
    # plt.tight_layout()
    fig.tight_layout(rect=[0, 0.03, 1, 0.95])
    # plt.show()
    plt.savefig(savepath, dpi=100)
    plt.close(fig)


def plot_task_grid(main_path, res_path, fname='plot_task-CME.png'):
  # mapper_config = 'mappers_cmev3.json'
  # main_path = '/scratch/groups/saggar/demapper-cme/{}'.format(mapper_config)
  # res_path = '/scratch/groups/saggar/demapper-cme/analysis/ch8_{}/plot_task-grids'.format(mapper_config)
  os.makedirs(res_path, exist_ok=True)
  
  sbjs = sorted([s for s in os.listdir(main_path) if s.startswith('SBJ')])
  mappers = sorted([m for m in os.listdir(os.path.join(main_path, sbjs[0])) if 'Mapper' in m])

  for mapper in tqdm(mappers):
      process_mapper(sbjs, mapper, main_path, res_path, fname)


if __name__ == '__main__':
  fire.Fire(plot_task_grid)
