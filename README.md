
Downloading msc data:

    mkdir -p data/msc/sub-MSC01
    pushd data/msc/sub-MSC01

    # Download data
    scp -r "hasegan@login.sherlock.stanford.edu:/oak/stanford/groups/saggar/demapper/data/msc/sub-MSC01/vc38671*" .
    scp -r "hasegan@login.sherlock.stanford.edu:/oak/stanford/groups/saggar/demapper/data/msc/sub-MSC01/sub-*" .

    popd

    