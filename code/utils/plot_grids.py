import fire
import os
import matplotlib.pyplot as plt
import numpy as np
from tqdm import tqdm
import math
from PIL import Image
import seaborn as sns

from .utils import filter_dataframe

def plot_image(img_path, ax):
    im = Image.open(img_path)
    img = np.array(im)
    ax.imshow(img)
    del img
    del im
    return ax


def plot_grid_sbjs(sbjs, mapper, main_path, res_path, fname):
    # Renamed from process_mapper
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


def multiplot_mappers_grid_sbjs(main_path, res_path, fname='plot_task-CME.png'):
  # Display for all mappers, a big plot with all subjects
  os.makedirs(res_path, exist_ok=True)
  
  sbjs = sorted([s for s in os.listdir(main_path) if s.startswith('SBJ')])
  mappers = sorted([m for m in os.listdir(os.path.join(main_path, sbjs[0])) if 'Mapper' in m])

  for mapper in tqdm(mappers):
      process_mapper(sbjs, mapper, main_path, res_path, fname)


def plot_grid_params(df, sbj, fname, x_field, x_vals, y_field, y_vals, main_path, res_path, prefix=''):
  # Plot a grid of mappers for one subject where the subplots are for the same subject
  sns.set(style = "whitegrid")
  savepath = os.path.join(res_path, '{}-{}{}'.format(sbj, prefix, fname))

  ncols = len(x_vals)
  nrows = len(y_vals)
  fsize = 20

  fig, axr = plt.subplots(nrows=nrows, ncols=ncols, figsize=(fsize * (ncols/nrows)*1.1,fsize))

  for r,(yval, axc) in enumerate(zip(y_vals, axr)):
    for c,(xval, ax) in enumerate(zip(x_vals, axc)):
      # Disable ax defaults
      ax.tick_params(left=False, bottom=False, labelleft=False, labelbottom=False)
      ax.spines['top'].set_visible(False)
      ax.spines['right'].set_visible(False)
      ax.spines['bottom'].set_visible(False)
      ax.spines['left'].set_visible(False)
      ax.grid(False)
      
      fdf = filter_dataframe(df, {x_field: [xval], y_field: [yval]})
      assert len(fdf) == 1
      mapper = fdf['mapper'].to_numpy()[0]
      
      img_path = os.path.join(main_path, sbj, mapper, fname)
      plot_image(img_path, ax)
      if c == 0:
        ax.set_ylabel(str(yval))
      if r == len(y_vals)-1:
        ax.set_xlabel(str(xval))

  plt.suptitle(mapper)
  fig.tight_layout(rect=[0, 0.03, 1, 0.95])
  plt.savefig(savepath, dpi=100)
  plt.close(fig)


if __name__ == '__main__':
  fire.Fire(multiplot_mappers_grid_sbjs)
