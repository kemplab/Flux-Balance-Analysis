function [results]=updateCD(text,parsed,note)
% Correct(Update) the species name according to a reference list of the names.
%
% USAGE:
%
%    [results] = updateCD(text, parsed, note)
%
% INPUTS:
%    text:            A matlab variable that saves the lines of the XML file.
%    parsed:          A parsed CD model structure generated by `parseCD` function.
%
% OPTIONAL INPUT:
%    note:            The default value is '0'; It can be set as 'true';
%                     Record the column number of the species that are to be
%                     replaced with a new name.
%
% OUTPUTS:
%    text:            The corrected lines of the XML file.
%    number:          The number of the line.
%    changdStrLines:  The changed line of text.
%    col:             Record the column number of the species that is to be
%                     replaced with a new species name.
%
% EXAMPLE:
%
%    [text, number, numberofchanges, col] = updateCD(annotedText, ref_corrected)

if nargin<3;
    ConductCol=0;
    col={};

elseif strcmp(note,'true')
    ConductCol=1;
    col={};
end

col_name=2; % the column 2 contains metabolite names.

ref=parsed.r_info;

pool={'<species (\w*)','<celldesigner:name>'}; % the format in CellDesiginer XML file
keywords={' name', ':nam'};
mark={'"','<'};

for i=1:length(pool);
     a=0;
    if i==2
        warning('starting the second round of the program');
    end

    str=pool{i}

    key=keywords{i}

    mark_key=mark{i}
    % str='<celldesigner:species(\w*) id=' ;

    for ln=1:length(text);

        line_species=regexpi(text(ln).str,str); % find the line that contains the string ('str').
        % dd=str2num({line_species})
        if ~isempty(line_species{1})
            % reText=cellstr(text(line).str)

            % if strcmpi(reText,ref.species{line,1})
            a=a+1;
            number(a,1)=ln;  % ln stores line number.
            % disp(line_species);%(number(a,1));
        end
    end
    if i==1;
        totalCount=length(number(:,1))
    else
        totalCount=totalCount;
    end

    changedStrLines={};
    nC=0;

    for d=1:totalCount  % d increase discretely from 1 to the end.

        nRxn=number(d,1); % d is the count, whereas nRxn contains the row number.
        if isfield(ref,'species');

            reText=cellstr(text(nRxn).str)
            %for nn=1:length(ref.species(:,1))
            sizeRef=size(ref.species);
            disp(sizeRef)
            disp(d);
            disp(col_name);
            disp(length(number(:,1)))


            if ~isempty(ref.species(d,col_name))
                %if strcmpi(text(line).str,ref.species{d,1});
                strd=strfind(reText,key) % ' name')
                if (~isempty(strd{1}))  % in some cases, the line does not contain ' name'.
                    %if (~isempty(str))

                    if iscell(reText) % convert cell type into string type
                        reText=reText{1};
                    else
                        error('the format of the reText is not right');
                    end
                    [p_st,p_ed]=position(reText,key,mark_key) % ' name')
                    fprintf(' the text: %s',reText);
                    ToBeRplaced=reText(p_st:p_ed);
                    % disp(ToBeRplaced);
                    %ToBeRplaced=ref.species{nn,3};
                    try
                        text(nRxn).str=strrep(text(nRxn).str,ToBeRplaced,ref.species{d,col_name})
                    catch
                        %                     disp(text(nRxn).str);
                        %                     disp(ToBeRplaced);
                        %                     dusp(ref.species{d,3});
                    end
                    nC=nC+1;
                    changedStrLines(nC,1)=text(nRxn).str;
                    fprintf('original text is %s and is replaced with %s',ToBeRplaced,ref.species{d,col_name});
                    if  ConductCol==1;
                    col{nC,1}=ToBeRplaced;
                    col{nC,2}=ref.species{d,col_name}
                    end
                end
                %end
            end
            %end
        else
            warning('cannot find the field name ''species''');
        end
    end
end


results.text=text;
results.number=number;
results.changedStrLines=changedStrLines;
results.col=col;


end


function [p_st,p_ed]=position(str_long,str_ID,mark)
%% name='metaid';

ind_pos=strfind(str_long,str_ID);
l=length(str_ID)+2;
try
    p_st=ind_pos(1)+l
catch
    error('cannot find the Keyword in the the line')
end
end_rem=strfind(str_long(p_st:end),mark) % '"');
p_ed=end_rem(1)+p_st-2;
% disp(ind_pos);
% disp(l);
% disp(p_ed)

end
