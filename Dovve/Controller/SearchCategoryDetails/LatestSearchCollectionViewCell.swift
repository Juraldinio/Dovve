//
//  LatestSearchCollectionViewCell.swift
//  Dovve
//
//  Created by Dheeraj Kumar Sharma on 01/10/20.
//  Copyright © 2020 Dheeraj Kumar Sharma. All rights reserved.
//

import UIKit

class LatestSearchCollectionViewCell: UICollectionViewCell {
 
    var dataModel:[SearchModel]?
    var dataList:[TweetData]?

    var query:String?{
        didSet {
            self.activityIndicator.startAnimating()
            SearchModel.fetchSearchModel(view:controller!,params:"&q=\(query!)&result_type=recent") {(dataModel) in
                self.dataModel = dataModel
                self.dataList?.removeAll()
                self.getDataListArray(dataModel)
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    let activityIndicator:UIActivityIndicatorView = {
        let ac = UIActivityIndicatorView()
        ac.translatesAutoresizingMaskIntoConstraints = false
        ac.tintColor = UIColor.dynamicColor(.secondaryTextColor)
        return ac
    }()
    
    var controller:SearchWithCategoryViewController?
    private lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = CustomColors.appBackground
        refreshControl.backgroundColor = UIColor.dynamicColor(.secondaryBackground)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    lazy var collectionView:UICollectionView = {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init())
        cv.refreshControl = refresher
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.register(SimpleTextPostCollectionViewCell.self, forCellWithReuseIdentifier: "SimpleTextPostCollectionViewCell")
        cv.register(PostWithImagesCollectionViewCell.self, forCellWithReuseIdentifier: "PostWithImagesCollectionViewCell")
        cv.register(QuotedPostCollectionViewCell.self, forCellWithReuseIdentifier: "QuotedPostCollectionViewCell")
        cv.register(QuotedPostWithImageCollectionViewCell.self, forCellWithReuseIdentifier: "QuotedPostWithImageCollectionViewCell")
        cv.register(PostWithImageAndQuoteCollectionViewCell.self, forCellWithReuseIdentifier: "PostWithImageAndQuoteCollectionViewCell")
        cv.register(PostWithImageAndQuotedImageCollectionViewCell.self, forCellWithReuseIdentifier: "PostWithImageAndQuotedImageCollectionViewCell")
        cv.setCollectionViewLayout(layout, animated: false)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor.dynamicColor(.secondaryBackground)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.dynamicColor(.secondaryBackground)
        addSubview(collectionView)
        addSubview(activityIndicator)
        collectionView.pin(to: self)
        setUpConstraints()
    }
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pullToRefresh(){
        SearchModel.fetchSearchModel(view:controller!,params:"&q=\(query!)&result_type=recent") {(dataModel) in
            self.dataModel = dataModel
            self.dataList?.removeAll()
            self.getDataListArray(dataModel)
            self.collectionView.reloadData()
        }
        refresher.endRefreshing()
    }
    
    func getDataListArray(_ data:[SearchModel]){
        var tweets = [TweetData]()
        let tweetCount = data.count
        for i in 0..<tweetCount{
            var mediaData = [TweetMediaData]()
            var quotedMediaData = [TweetMediaData]()
            
            if data[i].mediaData != nil {
                for j in 0..<data[i].mediaData.count {
                    let media = TweetMediaData(imgURL:data[i].mediaData[j].imgUrl, vidURL: data[i].mediaData[j].vidUrl, duration: data[i].mediaData[j].duration,isVideo: data[i].isVideo)
                    mediaData.append(media)
                }
            } else {
                mediaData = []
            }
            if data[i].isQuotedStatus == true {
                if data[i].quotedStatus.mediaData != nil {
                    for j in 0..<data[i].quotedStatus.mediaData.count {
                        let media = TweetMediaData(imgURL:data[i].quotedStatus.mediaData[j].imgUrl, vidURL: data[i].quotedStatus.mediaData[j].vidUrl, duration: data[i].quotedStatus.mediaData[j].duration, isVideo: data[i].quotedStatus.isVideo)
                        quotedMediaData.append(media)
                    }
                } else {
                    quotedMediaData = []
                }
                if data[i].isRetweetedStatus == true {
                    let tweet = TweetData(createdAt: data[i].createdAt, id: data[i].id, text: data[i].text, user: TweetUser(userId: data[i].user.userId, name: data[i].user.name, screenName: data[i].user.screen_name, profileImage: data[i].user.profileImage, isVerified: data[i].user.isVerified), media: mediaData , isVideo: data[i].isVideo,isRetweetedStatus: true, retweetedBy: TweetRetweetedData(userProfileImage: data[i].retweetedBy.userProfileImage, userID: data[i].retweetedBy.userID) ,isQuotedStatus: data[i].isQuotedStatus, tweetQuotedStatus:TweetQuotedStatus(createdAt: data[i].quotedStatus.createdAt, user: TweetUser(userId: data[i].quotedStatus.user.userId, name: data[i].quotedStatus.user.name, screenName: data[i].quotedStatus.user.screen_name, profileImage: data[i].quotedStatus.user.profileImage, isVerified: data[i].quotedStatus.user.isVerified), text: data[i].quotedStatus.text, media: quotedMediaData, isVideo: data[i].quotedStatus.isVideo), retweetCount: data[i].retweetCount, favoriteCount: data[i].favoriteCount, favorited: data[i].favorited, retweeted: data[i].retweeted, inReplyToStatusId: nil)
                    tweets.append(tweet)
                } else {
                    let tweet = TweetData(createdAt: data[i].createdAt, id: data[i].id, text: data[i].text, user: TweetUser(userId: data[i].user.userId, name: data[i].user.name, screenName: data[i].user.screen_name, profileImage: data[i].user.profileImage, isVerified: data[i].user.isVerified), media: mediaData, isVideo: data[i].isVideo,isRetweetedStatus: false , retweetedBy: nil , isQuotedStatus: data[i].isQuotedStatus, tweetQuotedStatus:TweetQuotedStatus(createdAt: data[i].quotedStatus.createdAt, user: TweetUser(userId: data[i].quotedStatus.user.userId, name: data[i].quotedStatus.user.name, screenName: data[i].quotedStatus.user.screen_name, profileImage: data[i].quotedStatus.user.profileImage, isVerified: data[i].quotedStatus.user.isVerified), text: data[i].quotedStatus.text, media: quotedMediaData, isVideo: data[i].quotedStatus.isVideo), retweetCount: data[i].retweetCount, favoriteCount: data[i].favoriteCount, favorited: data[i].favorited, retweeted: data[i].retweeted, inReplyToStatusId: nil)
                    tweets.append(tweet)
                }
            } else {
                if data[i].isRetweetedStatus == true {
                    let tweet = TweetData(createdAt: data[i].createdAt, id: data[i].id, text: data[i].text, user: TweetUser(userId: data[i].user.userId, name: data[i].user.name, screenName: data[i].user.screen_name, profileImage: data[i].user.profileImage, isVerified: data[i].user.isVerified), media: mediaData, isVideo: data[i].isVideo,isRetweetedStatus: true , retweetedBy: TweetRetweetedData(userProfileImage: data[i].retweetedBy.userProfileImage, userID: data[i].retweetedBy.userID), isQuotedStatus: data[i].isQuotedStatus, tweetQuotedStatus:nil, retweetCount: data[i].retweetCount, favoriteCount: data[i].favoriteCount, favorited: data[i].favorited, retweeted: data[i].retweeted, inReplyToStatusId: nil)
                    tweets.append(tweet)
                } else {
                    let tweet = TweetData(createdAt: data[i].createdAt, id: data[i].id, text: data[i].text, user: TweetUser(userId: data[i].user.userId, name: data[i].user.name, screenName: data[i].user.screen_name, profileImage: data[i].user.profileImage, isVerified: data[i].user.isVerified), media: mediaData, isVideo: data[i].isVideo,isRetweetedStatus: false, retweetedBy: nil ,isQuotedStatus: data[i].isQuotedStatus, tweetQuotedStatus:nil, retweetCount: data[i].retweetCount, favoriteCount: data[i].favoriteCount, favorited: data[i].favorited, retweeted: data[i].retweeted, inReplyToStatusId: nil)
                    tweets.append(tweet)
                }
            }
        }
        if dataList == nil {
            dataList = tweets
        } else {
            dataList?.append(contentsOf: tweets)
        }
    }
    
}

extension LatestSearchCollectionViewCell:UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataList = dataList {
            if dataList.count > 0 {
                return dataList.count
            }
            return 1
        }
        return Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let dataList = dataList {
            if dataList.count > 0 {
                if dataList[indexPath.row].media == [] && dataList[indexPath.row].isQuotedStatus == false {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimpleTextPostCollectionViewCell", for: indexPath) as! SimpleTextPostCollectionViewCell
                    cell.data = dataList[indexPath.row]
                    cell.delegate = self
                    return cell
                }
                if dataList[indexPath.row].media != [] &&  dataList[indexPath.row].isQuotedStatus == false {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostWithImagesCollectionViewCell", for: indexPath) as! PostWithImagesCollectionViewCell
                    cell.data = dataList[indexPath.row]
                    cell.delegate = self
                    return cell
                }
                if dataList[indexPath.row].media == [] && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media == [] {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuotedPostCollectionViewCell", for: indexPath) as! QuotedPostCollectionViewCell
                    cell.data = dataList[indexPath.row]
                    cell.delegate = self
                    return cell
                }
                if dataList[indexPath.row].media != [] && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media == [] {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostWithImageAndQuoteCollectionViewCell", for: indexPath) as! PostWithImageAndQuoteCollectionViewCell
                    cell.data = dataList[indexPath.row]
                    cell.delegate = self
                    return cell
                }
                if dataList[indexPath.row].media == [] && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media != [] {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuotedPostWithImageCollectionViewCell", for: indexPath) as! QuotedPostWithImageCollectionViewCell
                    cell.data = dataList[indexPath.row]
                    cell.delegate = self
                    return cell
                }
                if dataList[indexPath.row].media != [] && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media != [] {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostWithImageAndQuotedImageCollectionViewCell", for: indexPath) as! PostWithImageAndQuotedImageCollectionViewCell
                    cell.data = dataList[indexPath.row]
                    cell.delegate = self
                    return cell
                }
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCollectionViewCell", for: indexPath) as! DefaultCollectionViewCell
            cell.title.text = "No results for #\(query ?? "")"
            cell.subTitle.text = "The term you entered did not bring up any result."
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let dataList = dataList {
            if dataList.count > 0{
                if dataList[indexPath.row].media == [] && dataList[indexPath.row].isQuotedStatus == false {
                    let font = UIFont(name: CustomFonts.appFont, size: 17)!
                    let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                    return CGSize(width: collectionView.frame.width, height: estimatedH + 95 )
                }
                if dataList[indexPath.row].media != [] &&  dataList[indexPath.row].isQuotedStatus == false {
                    let font = UIFont(name: CustomFonts.appFont, size: 17)!
                    let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                    let extraHeight = 105 + ((collectionView.frame.width - 100) * (9 / 16))
                    return CGSize(width: collectionView.frame.width, height: estimatedH + extraHeight )
                }
                if dataList[indexPath.row].media == [] && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media == [] {
                    let font = UIFont(name: CustomFonts.appFont, size: 17)!
                    let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                    let estimatedHForQuotedTweet = dataList[indexPath.row].tweetQuotedStatus.text.height(withWidth: ((collectionView.frame.width - 100) - 30), font: font)
                    return CGSize(width: collectionView.frame.width, height: estimatedH + estimatedHForQuotedTweet + 160)
                }
                if dataList[indexPath.row].media != [] && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media == [] {
                    let font = UIFont(name: CustomFonts.appFont, size: 17)!
                    let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                    let estimatedHForQuotedTweet = dataList[indexPath.row].tweetQuotedStatus.text.height(withWidth: ((collectionView.frame.width - 100) - 30), font: font)
                    let imageCollectionForPostH = (collectionView.frame.width - 100) * (9/16)
                    return CGSize(width: collectionView.frame.width, height: estimatedH + estimatedHForQuotedTweet + imageCollectionForPostH + 175)
                }
                if dataList[indexPath.row].media == [] && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media != [] {
                    let font = UIFont(name: CustomFonts.appFont, size: 17)!
                    let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                    let estimatedHForQuotedTweet = dataList[indexPath.row].tweetQuotedStatus.text.height(withWidth: ((collectionView.frame.width - 100) - 30), font: font)
                    let imageCollectionHeight = ((collectionView.frame.width - 100) * (9/16))
                    return CGSize(width: collectionView.frame.width, height: estimatedH + estimatedHForQuotedTweet + imageCollectionHeight + 160)
                }
                if dataList[indexPath.row].media != [] && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media != [] {
                    let font = UIFont(name: CustomFonts.appFont, size: 17)!
                    let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                    let estimatedHForQuotedTweet = dataList[indexPath.row].tweetQuotedStatus.text.height(withWidth: ((collectionView.frame.width - 100) - 30), font: font)
                    let imageCollectionHeight = ((collectionView.frame.width - 100) * (9/16))
                    let imageCollectionForPostH = (collectionView.frame.width - 100) * (9/16)
                    return CGSize(width: collectionView.frame.width, height: estimatedH + estimatedHForQuotedTweet + imageCollectionHeight + imageCollectionForPostH + 175)
                }
            }
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.7
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            if let cell = collectionView.cellForItem(at: indexPath) as? SimpleTextPostCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? QuotedPostCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? QuotedPostWithImageCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? PostWithImagesCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? PostWithImageAndQuoteCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? PostWithImageAndQuotedImageCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
        }, completion: { _ in
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            if let cell = collectionView.cellForItem(at: indexPath) as? SimpleTextPostCollectionViewCell {
                cell.contentView.backgroundColor = .clear
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? QuotedPostCollectionViewCell {
                cell.contentView.backgroundColor = .clear
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? QuotedPostWithImageCollectionViewCell {
                cell.contentView.backgroundColor = .clear
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? PostWithImagesCollectionViewCell {
                cell.contentView.backgroundColor = .clear
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? PostWithImageAndQuoteCollectionViewCell {
                cell.contentView.backgroundColor = .clear
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? PostWithImageAndQuotedImageCollectionViewCell {
                cell.contentView.backgroundColor = .clear
            }
        }, completion: { _ in
        })
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let loadMoreFrom = collectionView.contentSize.height - (collectionView.contentSize.height * 30/100)
        if ((collectionView.contentOffset.y + collectionView.frame.size.height) >= loadMoreFrom){
            if let dataList = dataList {
                let totalPosts = dataList.count
                var getLastId = Int(dataList[totalPosts - 1].id)
                getLastId! -= 1
                SearchModel.fetchSearchModel(view:controller!,params:"&q=\(query!)&result_type=recent&max_id=\(getLastId ?? 0)") {(dataModel) in
                    self.getDataListArray(dataModel)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
}

extension LatestSearchCollectionViewCell: SimpleTextPostDelegate, PostWithImagesDelegate, QuotedPostDelegate, QuotedPostWithImageDelegate , PostWithImageAndQuoteDelegate , PostWithImageAndQuotedImageDelegate {
    
    func didHashtagTapped(_ hashtag: String) {
        controller?.SearchForHashtag(hashtag)
    }
    
    func didMentionTapped(screenName: String) {
        controller?.PushToProfile("", screenName)
    }
    
    func didUrlTapped(url: String) {
        let VC = WebViewController()
        VC.url = URL(string: url)
        let navVC = UINavigationController(rootViewController: VC)
        navVC.modalPresentationStyle = .fullScreen
        controller?.present(navVC, animated: true, completion: nil)
    }
    
    //MARK:-SimpleTextPost Actions
    func didUserProfileTapped(for cell: SimpleTextPostCollectionViewCell, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                controller?.PushToProfile(userId! , "")
            } else {
                let userId = dataList[indexPath.row].user.userId
                controller?.PushToProfile(userId! , "")
            }
        }
    }
    
    //MARK:-PostWithImages Actions
    func didUserProfileTapped(for cell: PostWithImagesCollectionViewCell, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                controller?.PushToProfile(userId! , "")
            } else {
                let userId = dataList[indexPath.row].user.userId
                controller?.PushToProfile(userId! , "")
            }
        }
    }
    
    func didImageTapped(for cell: PostWithImagesCollectionViewCell, _ index: Int) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if dataList[indexPath.row].isVideo {
                controller?.ShowVieoWithUrl(dataList[indexPath.row].media[0].vidURL)
            } else {
                let media = dataList[indexPath.row].media
                controller?.PushToImageDetailView(media! , index)
            }
        }
    }
    
    //MARK:-QuotedPost Actions
    func didUserProfileTapped(for cell: QuotedPostCollectionViewCell, _ isQuotedUser: Bool, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                controller?.PushToProfile(userId! , "")
            } else if isQuotedUser {
                let userId = dataList[indexPath.row].tweetQuotedStatus.user.userId
                controller?.PushToProfile(userId! , "")
            } else {
                let userId = dataList[indexPath.row].user.userId
                controller?.PushToProfile(userId! , "")
            }
        }
    }
    
    //MARK:-QuotedPostWithImage Actions
    func didUserProfileTapped(for cell: QuotedPostWithImageCollectionViewCell, _ isQuotedUser: Bool, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                controller?.PushToProfile(userId! , "")
            } else if isQuotedUser {
                let userId = dataList[indexPath.row].tweetQuotedStatus.user.userId
                controller?.PushToProfile(userId! , "")
            } else {
                let userId = dataList[indexPath.row].user.userId
                controller?.PushToProfile(userId! , "")
            }
        }
    }
    
    func didImageTapped(for cell: QuotedPostWithImageCollectionViewCell, _ index: Int) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if dataList[indexPath.row].tweetQuotedStatus.isVideo {
                controller?.ShowVieoWithUrl(dataList[indexPath.row].tweetQuotedStatus.media[0].vidURL)
            } else {
                let media = dataList[indexPath.row].tweetQuotedStatus.media
                controller?.PushToImageDetailView(media! , index)
            }
        }
    }
    
    //MARK:-PostWithImageAndQuote Actions
    func didUserProfileTapped(for cell: PostWithImageAndQuoteCollectionViewCell, _ isQuotedUser: Bool, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                controller?.PushToProfile(userId! , "")
            } else if isQuotedUser {
                let userId = dataList[indexPath.row].tweetQuotedStatus.user.userId
                controller?.PushToProfile(userId! , "")
            } else {
                let userId = dataList[indexPath.row].user.userId
                controller?.PushToProfile(userId! , "")
            }
        }
    }
    
    func didImageTapped(for cell: PostWithImageAndQuoteCollectionViewCell, _ index: Int) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if dataList[indexPath.row].isVideo {
                controller?.ShowVieoWithUrl(dataList[indexPath.row].media[0].vidURL)
            } else {
                let media = dataList[indexPath.row].media
                controller?.PushToImageDetailView(media!, index)
            }
        }
    }
    
    //MARK:-PostWithImageAndQuotedImage Actions
    func didUserProfileTapped(for cell: PostWithImageAndQuotedImageCollectionViewCell, _ isQuotedUser: Bool , _ isRetweetedUser:Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                controller?.PushToProfile(userId! , "")
            } else if isQuotedUser {
                let userId = dataList[indexPath.row].tweetQuotedStatus.user.userId
                controller?.PushToProfile(userId! , "")
            } else {
                let userId = dataList[indexPath.row].user.userId
                controller?.PushToProfile(userId! ,"")
            }
        }
    }
    
    func didImageTapped(for cell: PostWithImageAndQuotedImageCollectionViewCell, _ index: Int, isPostImage: Bool, isQuoteImage: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isPostImage {
                if dataList[indexPath.row].isVideo {
                    controller?.ShowVieoWithUrl(dataList[indexPath.row].media[0].vidURL)
                } else {
                    let media = dataList[indexPath.row].media
                    controller?.PushToImageDetailView(media! , index)
                }
            } else if isQuoteImage {
                if dataList[indexPath.row].tweetQuotedStatus.isVideo {
                    controller?.ShowVieoWithUrl(dataList[indexPath.row].tweetQuotedStatus.media[0].vidURL)
                } else {
                    let media = dataList[indexPath.row].tweetQuotedStatus.media
                    controller?.PushToImageDetailView(media! , index)
                }
            }
        }
    }
    
}
