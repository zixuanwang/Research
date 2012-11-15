% 10/4/2012
% for a (eid, iid, uid, vote)
% compute the cumulative positive votes for (eid, iid) 
% and the cumulative negative votes for (eid, iid)

a = load('../full_instance_orderby_event_date.txt');
A = a(:,1:4);
 
rows = size(A,1);
cols = size(A,2);
existing_pos = zeros(rows,1);
existing_neg = zeros(cols,1);

for i=2:rows  %ignore the first one 
    current_instance = A(i,:); 
    this_event = current_instance(1);
    this_item = current_instance(2);
    this_user = current_instance(3);
    
    pos_sofar = nnz((A(1:(i-1),1)== this_event) &(A(1:(i-1),2)==this_item) &(A(1:(i-1),4)==1));
    neg_sofar = nnz((A(1:(i-1),1)== this_event) &(A(1:(i-1),2)==this_item) &(A(1:(i-1),4)==-1));
    
    existing_pos(i) = pos_sofar;
    existing_neg(i) = neg_sofar;
end

B = [A,existing_pos, existing_neg];
dlmwrite('output/full_instance_orderby_event_date_with_existingvote_count.txt',B);


% how many positive/neg votes are given considering the existing positive votes. 
uniqe_existing_pos = unique(existing_pos);
posvote_count_after_existing_pos = zeros(uniqe_existing_pos,1);
negvote_count_after_existing_pos = zeros(uniqe_existing_pos,1);
for i=1:length(uniqe_existing_pos)
    cnt = uniqe_existing_pos(i);
    vote = B(:,4);
    posvote_count_after_existing_pos(i) =  nnz(vote == 1 & existing_pos==cnt);
    negvote_count_after_existing_pos(i) =  nnz(vote == -1 & existing_pos==cnt);
end

 posvote_withexisting_pos = [uniqe_existing_pos, posvote_count_after_existing_pos', negvote_count_after_existing_pos'];
 
 dlmwrite('output/pos_neg_votes_given_existing_posvote.txt',posvote_withexisting_pos)
 
 % how many positive/neg  votes are given considering the existing negative
 % votes
uniqe_existing_neg = unique(existing_neg);
posvote_count_after_existing_neg = zeros(1,uniqe_existing_neg);
negvote_count_after_existing_neg = zeros(1,uniqe_existing_neg);
for i=1:length(uniqe_existing_neg)
    cnt = uniqe_existing_pos(i);
    vote = B(:,4);
    posvote_count_after_existing_neg(i) =  nnz(vote == 1 & existing_neg==cnt);
    negvote_count_after_existing_neg(i) =  nnz(vote == -1 & existing_neg==cnt);
end

 posvote_withexisting_neg = [uniqe_existing_neg, posvote_count_after_existing_neg', negvote_count_after_existing_neg'];
 
 dlmwrite('output/pos_neg_votes_given_existing_negvote.txt',posvote_withexisting_neg)
 
 % plot the difference 
 % given positive votes
    h1=figure();set(h1,'PaperSize',[6 4]);set(h1,'PaperPosition',[0 0 6 4]);
    ax1 =subplot(1,1,1);
    set(ax1,'FontSize',20)
    set(ax1,'LineWidth',2);
    bar(posvote_withexisting_pos(2:end,1),posvote_withexisting_pos(2:end,2:3))
    legend('Positive Votes', 'Negative votes')
    xlabel('number of existing positive votes')
    ylabel('number of instances')
    %title('Pos/Neg votes given the number of existing positive votes')
 
 % given negative votes
    h1=figure();set(h1,'PaperSize',[6 4]);set(h1,'PaperPosition',[0 0 6 4]);
    ax1 =subplot(1,1,1);
    set(ax1,'FontSize',20)
    set(ax1,'LineWidth',2);
    bar(posvote_withexisting_neg(2:end,1),posvote_withexisting_neg(2:end,2:3))
    legend('Positive Votes', 'Negative votes')
    xlabel('number of existing negative votes')
    ylabel('number of instances')
    %title('Pos/Neg votes given the number of existing positive votes')
 
 
    
 