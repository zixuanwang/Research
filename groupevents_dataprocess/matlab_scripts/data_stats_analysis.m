files = dir('../user_instance/*.dat');
for i = 1:numel(files)
    filename = strcat('../user_instance/', files(i).name)
    data = load(filename);
    y = data(:,43);
    y(y==-1)=0;
    nnz(y)/size(y,1)
end


% how many events have more than one items that get maximum votes?
    all_events = load('../recommendation_input/event_item_vote.txt');
    all_groups = load('../recommendation_input/event_user.txt');
    
    n_events = 0;
    equal_max = 0;
  
    pos_vote_ratio=zeros(280,1);
    for i=1:280 
        % get the event polling information.  the first column is the event
        % id
        a_event = all_events(all_events(:,1)==i,:);
        if isempty(a_event)
            continue;
        end
        n_events = n_events +1;
        
        %get the group information for this event 
        the_group = all_groups(all_groups(:,1)==i,:);
        users = the_group(:,2);
        items = a_event(:,2);
        
        %sort item id by pos votes in ascending order
        A = sortrows(a_event,3);
        asc_pos_votes = A(:,3);
        asc_neg_votes = A(:,4);
        ranked_itemid = A(:,2);
        
        max_val = asc_pos_votes(end);
        pos_vote_ratio(i) = max_val/length(users);
        % get indexs of maximum values if more than one maximum
        max_tidxs = ranked_itemid(asc_pos_votes==max_val);
        if nnz(max_tidxs)>1
            equal_max = equal_max+1;
        end
    end
    
    fprintf('out of %d events, %d have equal_max items.',n_events,equal_max);
    
%################### PLOT ##############################
    
    %plot the ratio of maximal votes to the group size.
    
    valid_pos_vote_ratio = pos_vote_ratio(pos_vote_ratio>0);
    h1=figure();set(h1,'PaperSize',[6 4]);set(h1,'PaperPosition',[0 0 6 4]);
    ax1 =subplot(1,1,1);
    set(ax1,'FontSize',20)
    hist(valid_pos_vote_ratio,0:0.1:1);
    ylabel('Number of events')
    xlabel('ratio of maximal positive votes to group size')
    
    % plot cdf of the ratio. 
    
    h1=figure();set(h1,'PaperSize',[6 4]);set(h1,'PaperPosition',[0 0 6 4]);
    ax1 =subplot(1,1,1);
    set(ax1,'FontSize',20)
    h = cdfplot(valid_pos_vote_ratio);
    set(h,'linewidth',2)
    ylabel('cumulative ratio of events')
    xlabel('ratio of maximal positive votes to group size')
    
    

    % plot cdf of accuracy.

	acc = load('../logit_lastevent_accuracy.txt');
    h1=figure();set(h1,'PaperSize',[6 4]);set(h1,'PaperPosition',[0 0 6 4]);
    ax1 =subplot(1,1,1);
    set(ax1,'FontSize',20)
    h = cdfplot(acc(:,2));
    set(h,'linewidth',2)
    ylabel('F(x)')
    xlabel('x= accuracy on test data')
    hold on 
	itemonly = load('../serialized_logit_itemonly_accuracy.txt');
	B = sortrows(itemonly,1);
	
	h2 = cdfplot(B(:,3))
	set(h2,'linewidth',2, 'marker','o','color','r')
	hold off
	itemuser = load('../serialized_logit_itemuser_accuracy.txt');
	C = sortrows(itemuser,1);
	hold on 
	h3 = cdfplot(C(:,3))
	set(h3,'linewidth',2, 'marker','*','color','black')
	legend('itemonly+last event','itemonly','item+user')
 
    
    % plot ROC on the training set
    
    a = dlmread('output/itemonly_train_predtrue_sorted.txt');
    b = dlmread('output/itemuser_train_predtrue_sorted.txt');
    c= dlmread('output/withlastitem_train_predtrue_sorted.txt');
    d = dlmread('output/withexistingvote_train_predtrue_sorted.txt'); 
    p = nnz(a(:,2));
    n = sum(~a(:,2));
    tp = cumsum(a(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
   
    h1=figure();set(h1,'PaperSize',[6 4]);set(h1,'PaperPosition',[0 0 6 4]);
    ax1 =subplot(1,1,1);
    set(ax1,'FontSize',20)
    set(ax1,'LineWidth',1.2);
    plot(fpr,tpr)
    
    hold on
  
    p = nnz(b(:,2));
    n = sum(~b(:,2));
    tp = cumsum(b(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    plot(fpr,tpr,'m');
    
    p = nnz(c(:,2));
    n = sum(~c(:,2));
    tp = cumsum(c(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    plot(fpr,tpr,'g');
   
    p = nnz(d(:,2));
    n = sum(~d(:,2));
    tp = cumsum(d(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    plot(fpr,tpr,'r');
    xlim([0,1])
    xlabel('False positive rate')
    ylabel('True positive rate')
    legend('item only','item+user','item+last event','item+existing votes')
    title('ROC curve on training set')
    
    
    % plot ROC on test set
    a = dlmread('output/itemonly_test_predtrue_sorted.txt');
    b = dlmread('output/itemuser_test_predtrue_sorted.txt');
    c = dlmread('output/withlastitem_test_predtrue_sorted.txt');
    d = dlmread('output/withexistingvote_test_predtrue_sorted.txt'); 
    p = nnz(a(:,2));
    n = sum(~a(:,2));
    tp = cumsum(a(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
   
    h1=figure();set(h1,'PaperSize',[6 4]);set(h1,'PaperPosition',[0 0 6 4]);
    ax1 =subplot(1,1,1);
    set(ax1,'FontSize',20)
    set(ax1,'LineWidth',2);
    plot(fpr,tpr)
    
    hold on
  
    p = nnz(b(:,2));
    n = sum(~b(:,2));
    tp = cumsum(b(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    plot(fpr,tpr,'m');
    
    p = nnz(c(:,2));
    n = sum(~c(:,2));
    tp = cumsum(c(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    plot(fpr,tpr,'g');
    
     
    p = nnz(d(:,2));
    n = sum(~d(:,2));
    tp = cumsum(d(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    plot(fpr,tpr,'r');
    
    xlim([0,1])
    xlabel('False positive rate')
    ylabel('True positive rate')
    legend('item only','item+user','item+last event','item+existing votes')
    title('ROC curve on test set')
    
    
    % compute AUC  area under curve on the test set
    a = dlmread('output/itemonly_test_predtrue_sorted.txt');
    b = dlmread('output/itemuser_test_predtrue_sorted.txt');
    c= dlmread('output/withlastitem_test_predtrue_sorted.txt');

    p = nnz(a(:,2));
    n = sum(~a(:,2));
    tp = cumsum(a(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    aucA = trapz(fpr,tpr);
    
    p = nnz(b(:,2));
    n = sum(~b(:,2));
    tp = cumsum(b(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    aucB = trapz(fpr,tpr);    
    
    p = nnz(c(:,2));
    n = sum(~c(:,2));
    tp = cumsum(c(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    aucC = trapz(fpr,tpr);
    

    p = nnz(d(:,2));
    n = sum(~d(:,2));
    tp = cumsum(d(:,2));
    fpr = tp./n;
    tpr = (p-tp)./p;
    tpr = flipdim(tpr,1);
    aucD = trapz(fpr,tpr);
    