%  AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
%   Math/Statistics:   Connor Meehan <connor.gw.meehan@gmail.com>
%                      Guenther Walther <gwalther@stanford.edu>
%   Primary inventors: Wayne Moore <wmoore@stanford.edu>
%                      David Parks <drparks@stanford.edu>
%   Provided by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%
classdef SuhMatchListener < handle
    properties(SetAccess=private)
        roiTableTraining=[];
        roiTableTest=[];
        trainingIds;
        testIds;
        trainingSet;
        testSet;
        trainingSetName='Training set';
        testSetName='Test set';
        table;
        columnNames;
        isTrainingSuhDataSet;
        isTestSuhDataSet;
        lastIsTeachers;
        lastQfIdxs;
    end
    
    properties
        explorerName='DImension';
        btnsObj;
    end
    
    methods
        function this=SuhMatchListener(matchTable, columnNames,...
                trainingSet, testSet, trainingIds,  testIds, ...
                trainingSetName, testSetName, parseFileNameOut)
            this.table=matchTable;
            this.columnNames=columnNames;
            this.trainingSet=trainingSet;
            this.isTrainingSuhDataSet=isa(trainingSet, 'SuhDataSet');
            if nargin>3
                this.testSet=testSet;
                this.isTestSuhDataSet=isa(testSet, 'SuhDataSet');
                if nargin>4
                    this.trainingIds=trainingIds;
                    this.testIds=testIds;
                    if nargin>6
                        if nargin>8 && parseFileNameOut
                            [~,trainingSetName]=fileparts(trainingSetName);
                            [~,testSetName]=fileparts(testSetName);
                        end
                        this.trainingSetName=[this.trainingSetName ': ' ...
                            trainingSetName];
                        this.testSetName=[this.testSetName ': ' ...
                            testSetName];
                    end
                end
            elseif this.isTrainingSuhDataSet
                this.testIds=this.trainingSet.getTestSetLabels;
            end
            if nargin<5
                if this.isTrainingSuhDataSet
                    [~,trainingSetName]=fileparts(trainingSet.file);
                    this.trainingSetName=[this.trainingSetName ': ' ...
                            trainingSetName];                            
                end
            end
        end
        
        function reselect(this)
            if ~isempty(this.lastIsTeachers)
                this.select(this.table.qf, this.lastIsTeachers, this.lastQfIdxs);
            end
        end
        
        function select(this, qf, isTeachers, qfIdxs)
            this.lastIsTeachers=isTeachers;
            this.lastQfIdxs=qfIdxs;
            if ~isempty(this.table.cbSyncKld) 
                edu.stanford.facs.swing.Basics.Shake(this.table.cbSyncKld, 3);                
                if ~this.table.cbSyncKld.isSelected
                    return;
                end
            end
            [names, lbls]=QfHiDM.GetNamesLbls(qf, isTeachers, qfIdxs, ...
                this.btnsObj);
            this.updateRoi(names, isTeachers, true, lbls);
            this.updateRoi(names, isTeachers, false, lbls);
        end
        
        function dataSubset=getTrainingSubset(this, lbls, isTestSet)
            if this.isTrainingSuhDataSet
                if isTestSet
                    dataSubset=this.trainingSet.data(...
                        MatBasics.LookForIds2(this.testIds, lbls),:);
                elseif ~isempty(this.trainingIds)
                    dataSubset=this.trainingSet.data(...
                        MatBasics.LookForIds2(this.trainingIds, lbls),:);
                else
                    dataSubset=this.trainingSet.data(...
                        MatBasics.LookForIds2(this.trainingSet.labels, lbls),:);
                end
            else
                if isempty(this.trainingIds)
                    warn('Showing all data... no labels/ids for %s', ...
                        this.trainingName);
                    dataSubset=this.trainingSet;
                elseif isTestSet
                    dataSubset=this.trainingSet(...
                        MatBasics.LookForIds2(this.testIds, lbls),:);
                else
                    dataSubset=this.trainingSet(...
                        MatBasics.LookForIds2(this.trainingIds, lbls),:);
                end
            end
        end

        function dataSubset=getTestSubset(this, lbls)
            if isempty(this.testSet)
                dataSubset=this.getTrainingSubset(lbls,true);
            elseif this.isTestSuhDataSet
                if ~isempty(this.testIds)
                    dataSubset=this.testSet.data(...
                        ismember(this.testIds, lbls),:);
                else
                    dataSubset=this.testSet.data(...
                        MatBasics.LookForIds2(this.testSet.labels, lbls),:);
                end
            else
                if isempty(this.testIds)
                    warn('Showing all data... no labels/ids for %s', ...
                        this.testName);
                    dataSubset=this.testSet;
                else
                    dataSubset=this.testSet(...
                        MatBasics.LookForIds2(this.testIds, lbls),:);
                    if ~isempty(this.table.predictions)
                        this.table.predictions.selected(lbls);
                    end
                end
            end
        end

        function updateRoi(this, names, isTeachers, doTeacher, lbls)
            lbls=lbls(isTeachers==doTeacher);
            names=names(find(isTeachers==doTeacher));
            if isempty(lbls)
                return;
            end
            if doTeacher
                roiTable=this.roiTableTraining;
                dataSubset=this.getTrainingSubset(lbls,false);
            else
                roiTable=this.roiTableTest;
                dataSubset=this.getTestSubset(lbls);
            end
            try
                needToMake=isempty(roiTable) ...
                    || ~ishandle(roiTable.table.table.fig);
            catch
                needToMake=true;
            end
            name=names{1};
            nSubsets=length(names);
            if nSubsets>1
                name=sprintf('%s and %s', name, ...
                    String.Pluralize2('other', nSubsets-1));
            end
            if needToMake
                if doTeacher
                    dataSetName=this.trainingSetName;
                    where='south west++';
                    whereAssociate='west++';
                    otherTable=this.roiTableTest;
                else
                    if isequal(this.testSetName, 'Test set')
                        this.testSetName=strrep(this.trainingSetName, ...
                            'Training set', 'Test set');
                    end
                    dataSetName=this.testSetName;
                    where='south++';
                    whereAssociate='east++';
                    otherTable=this.roiTableTraining;
                end
                if isempty(otherTable) || ~Gui.IsFigure(otherTable.getFigure)
                    if Gui.IsFigure(this.table.qHistFig)
                        if ~isequal(where, 'south west++')
                            where='south east++';
                        end
                        followed=this.table.qHistFig;
                    elseif Gui.IsFigure(this.table.fHistFig)
                        if ~isequal(where, 'south west++')
                            where='south++';
                        end
                        followed=this.table.fHistFig;
                    else
                        followed=this.table.fig;
                    end
                else
                    where=whereAssociate;
                    followed=otherTable.getFigure;
                end
                roiTable=Kld.Table(dataSubset,  this.columnNames, ...
                    [], followed, name, where, this.explorerName, ...
                    dataSetName, false, [], {followed, where, true});
                if doTeacher
                    this.roiTableTraining=roiTable;
                else
                    this.roiTableTest=roiTable;
                end
            else
                figure(roiTable.getFigure);
                roiTable.refresh(dataSubset, name);
                figure(this.table.fig);
            end
        end
    end
end