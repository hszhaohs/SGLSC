# SGLSC
The code of paper [Superpixel-level Global and Local Similarity Graph-based Clustering for Large Hyperspectral Images](https://ieeexplore.ieee.org/abstract/document/9641802/).

```
@ARTICLE{9641802,
  author={Zhao, Haishi and Zhou, Fengfeng and Bruzzone, Lorenzo and Guan, Renchu and Yang, Chen},
  journal={IEEE Transactions on Geoscience and Remote Sensing},
  title={Superpixel-Level Global and Local Similarity Graph-Based Clustering for Large Hyperspectral Images},
  year={2022},
  volume={60},
  number={},
  pages={1-16},
  doi={10.1109/TGRS.2021.3132683}}
```


## Usage

For example, if you want to perform SGLSC:

1. Prepare data and put it under `./data`
2. Modify the parameters in `run_SGLSC_HSI.m` as you need
3. Run `run_SGLSC_HSI.m`


## References

[1] The code of superpixel segmentation (i.e., the filefolder of `./src/EntropyRateSuperpixel-master`) is cloned from https://github.com/mingyuliutw/EntropyRateSuperpixel

[2] The solving process of sparse self-representation (i.e., the filefolder of `./src/SSC_ADMM_v1.1`) is referred to [The Vision, Dynamics and Learning Lab](http://vision.jhu.edu/code/).



## License

SGLSC is free software made available under the MIT License. For details see the LICENSE.md file.
