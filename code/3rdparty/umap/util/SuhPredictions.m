classdef SuhPredictions < handle
    
%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
%   Math Lead & Secondary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
%   Bioinformatics Lead:  Wayne Moore <wmoore@stanford.edu>
%   Provided by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%

properties(Constant)
    FALSE_NEG=.3;
    FALSE_POS=.2;
    TRUE_POS=.1;
    DEBUG=false;
end
properties(SetAccess=private)
    R;
    nTeachers;
    match; %instance of QfHiDM for original match on same data
    matchPosNeg;%instance of QfHiDM for predicted matches to true+ & true +/0
    tablePosNeg;
    sNames={};
    posNegLbls;
    posLbls;
    negLbls;
    sums;
    ids;
    contentPane;
    columnName;
end

properties
    table; %instance of QfTable  for original match on same data
end
methods
    function this=SuhPredictions(match)
        this.sums=[];
        this.setMatch(match);
        this.R=size(this.match.tData,1);
        this.nTeachers=length(this.match.tNames);
        this.prepare;
    end
    
    function clearMatchObject(this)
        this.match=[];
        this.table=[];
    end
    
    function setMatch(this, match)
        if isa(match, 'QfTable')
            this.match=match.qf;
            this.table=match;
        else
            this.match=match;
        end
    end
    function [similarity, overlap, tName, tId, ti, si, words]=describe(this, id)
        qf=this.matchPosNeg;
        tId=floor(id);
        ti=find(qf.tIds==tId,1);
        tName=qf.tNames{ti};
        strId=num2str(id);
        if endsWith(strId, '.3') % false -
            word='false negatives';
        elseif endsWith(strId, '.2') % false +
            word='false positives';
        elseif endsWith(strId, '.1') % true +
            word='true positives';
        else % training set
            similarity=nan;
            overlap=nan;
            words='';
            si=nan;
            return;
        end
        si=find(qf.sIds==id,1);
        overlap=1-qf.matrixUnmerged(si,ti);
        similarity=1-qf.distance(id, tId);
        if nargout>6
            words=['<b>' word '</b> are ' ...
                ' <u>' String.encodePercent(similarity, 1,1) ...
                ' similar</u> to "<i>' String.RemoveTex( tName ) ...
                '</i>" (' String.encodePercent(overlap,1,1) ' overlap)'];
        end
    end
    
    function selected(this, ids)
        qf=this.matchPosNeg;
        N=length(ids);
        bullets={};
        for i=1:N
            [~,~,~,~,~,~,words]=this.describe(ids(i));
            if ~isempty(words)
                bullets{end+1}=words;
            end
        end
        if ~isempty(bullets)
            if N==1
                tip=bullets{1};
            else
                tip=Html.ToListItemsAreHtml(bullets, 'ul');
            end
            if isempty(this.contentPane)
                this.contentPane=...
                    Gui.JWindow(this.tablePosNeg.fig).getContentPane;
            end
            this.tablePosNeg.app.showToolTip(...
                this.contentPane, Html.WrapTable(tip, 11), 10, 5, 8);
        end
    end
    
    function prepare(this)
        this.contentPane=[];
        [this.posLbls, this.negLbls, this.sNames, this.sums, this.ids]...
            =SuhPredictions.Get(this.match);
    end
    
    function tablePosNeg=showTable(this, locate_fig, pu)
        if ~isempty(this.tablePosNeg)
            if Gui.IsVisible(this.tablePosNeg.fig)
                figure(this.tablePosNeg.fig);
                tablePosNeg=this.tablePosNeg;
                return;
            end
        end
        if nargin<3
            if ~isempty(this.table) && ishandle(this.table.fig)
                set(0, 'CurrentFigure', this.table.fig)
            end
            pu=PopUp('Matching predicted to predictions', 'center', ...
                'Analyzing prediction accuracy');
            if nargin<2
                locate_fig={};
            end
        end
        if isempty(this.posLbls)
            this.prepare;
        end
        if isempty(locate_fig)
            if ~isempty(this.table) && ishandle(this.table.fig)
                locate_fig={this.table.fig, 'south east+', true};
            else
                locate_fig=true;
            end
        end
        this.contentPane=[];
        m=this.match;
        sIdPerRow=[this.posLbls;this.negLbls]';
        if isempty(this.matchPosNeg)
            this.matchPosNeg=run_HiD_match(m.tData, m.tIdPerRow, ...
                m.tData, sIdPerRow, 'mergeStrategy', -1,...
                'trainingNames', m.tNames, 'matchStrategy', 2, ...
                'log10', true, 'testNames', this.sNames, 'pu', pu);
        end
        this.tablePosNeg=QfTable(this.matchPosNeg, m.tClrs, [], ...
            get(0, 'currentFig'), locate_fig, [], '', this);
        listener=this.tablePosNeg.listen(this.match.columnNames, ...
            m.tData, m.tData, m.tIdPerRow, sIdPerRow, ...
            'predicted', 'true+|false+/- ');
        if isempty(this.columnName)
            listener.explorerName='Dimension';
        else
            listener.explorerName=this.columnName; %for window title
        end
        if nargin<3
            pu.close(true, false);
        end
        tablePosNeg=this.tablePosNeg;
    end
end

methods(Static)
    function [pos, neg, names, sums, ids]=Get(qf)
        if isempty(qf.falsePosEvents)
            qf.getFalsePosNegRecords
        end
        if isempty(qf.falsePosEvents)
            pos=[];
            neg=[];
            names=[];
            sums=[];
            ids=[];
            return;
        end
        N=length(qf.falsePosEvents);
        pos=zeros(1, N);
        neg=zeros(1, N);
        N1=length(qf.tIds);
        names={};
        sums=[];
        ids=[];
        done=0;
        for i=1:N1
            tId=qf.tIds(i);
            [ti, truePosIdxs, falsePosIdxs, falseNegIdxs]...
                =qf.getPredictions(tId, QfHiDM.DEBUG_LEVEL>0);
            if isempty(falsePosIdxs) && isempty(falseNegIdxs)...
                    && isempty(truePosIdxs) %don't rule out perfect prediction
                continue;
            end
            tName=qf.tNames{ti};
            done=done+1;
            sums(done,1)=tId;
            sums(done,2)=qf.tSizes(ti);
            addIdxs([tName ' true+'], 1, truePosIdxs);
            addIdxs([tName ' false+'], 2, falsePosIdxs);
            addIdxs([tName ' false-'], 3, falseNegIdxs);
            if SuhPredictions.DEBUG
                assert(isequal(qf.idxsFalseNeg{ti}, falseNegIdxs));
                assert(isequal(qf.idxsFalsePos{ti}, falsePosIdxs));
                assert(isequal(qf.idxsTruePos{ti}, truePosIdxs));
            end
        end
        
        function addIdxs(name, which, idxs)
            if isempty(idxs)
                return;
            end
            names{end+1}=name;
            ids(end+1)=tId+(which/10);
            
            if which<3
                pos(idxs)=ids(end);
            else
                neg(idxs)=ids(end);
            end
            sums(done, 2+which)=length(idxs);
        end
    end
    
    function [this, table]=New(qf, locate_fig, pu, columnName)
        this=[];
        table=[];
        if isstruct(qf)
            if isfield(qf, 'predictions')
                this=qf.predictions;
                this.setMatch(qf);
            end
        elseif isa(qf, 'QfHiDM')
            this=SuhPredictions(qf);
        end
        if nargin>3
            this.columnName=columnName;
        end
        if isempty(this)
            warning('Can not instantiate SuhPredictions ?');
        else
            if nargin<3
                pu=[];
                if nargin<2
                    locate_fig=[];
                end
            end
            table=this.showTable(locate_fig, pu);
        end
    end
end
end