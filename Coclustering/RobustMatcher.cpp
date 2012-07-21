#include "RobustMatcher.h"

RobustMatcher::RobustMatcher() :
		ratio(0.75), distance(1.0) {
	// SURF is the default feature
	detector = new cv::SurfFeatureDetector();
	extractor = new cv::SurfDescriptorExtractor();
}

RobustMatcher::~RobustMatcher() {
	// TODO Auto-generated destructor stub
}

cv::Mat RobustMatcher::match(const cv::Mat& image1, const cv::Mat& image2,
		std::vector<cv::KeyPoint>* pKeypoint1,
		std::vector<cv::KeyPoint>* pKeypoint2) {
	pKeypoint1->clear();
	pKeypoint2->clear();
	if (image1.empty() || image2.empty()) {
		return cv::Mat();
	}
	std::vector<cv::DMatch> matchArray;
	std::vector<cv::KeyPoint> keypoint1;
	std::vector<cv::KeyPoint> keypoint2;
	cv::Mat imageDescriptor1;
	cv::Mat imageDescriptor2;
	BoWDescriptor::instance()->extractDescriptor(&keypoint1, &imageDescriptor1,
			image1);
	BoWDescriptor::instance()->extractDescriptor(&keypoint2, &imageDescriptor2,
			image2);
	cv::BFMatcher matcher(cv::NORM_L2);
	// from image 1 to image 2
	// based on k nearest neighbours (with k=2)
	std::vector<std::vector<cv::DMatch> > matches1;
	matcher.knnMatch(imageDescriptor1, imageDescriptor2, matches1, // vector of matches (up to 2 per entry)
			2);
	// return 2 nearest neighbours
	// from image 2 to image 1
	// based on k nearest neighbours (with k=2)
	std::vector<std::vector<cv::DMatch> > matches2;
	matcher.knnMatch(imageDescriptor2, imageDescriptor1, matches2, // vector of matches (up to 2 per entry)
			2);
	// return 2 nearest neighbours
	// 3. Remove matches for which NN ratio is
	// > than threshold
	// clean image 1 -> image 2 matches
	ratioTest(matches1);
	// clean image 2 -> image 1 matches
	ratioTest(matches2);
	// 4. Remove non-symmetrical matches
	std::vector<cv::DMatch> symMatches;
	symmetryTest(matches1, matches2, symMatches);
	if (symMatches.size() < 4) {
		return cv::Mat();
	}
	// 5. Validate matches using RANSAC
	cv::Mat homography = ransacTest(symMatches, keypoint1, keypoint2,
			matchArray);
	for (size_t i = 0; i < matchArray.size(); ++i) {
		pKeypoint1->push_back(keypoint1[matchArray[i].queryIdx]);
		pKeypoint2->push_back(keypoint2[matchArray[i].trainIdx]);
	}
	// return the found homography matrix
	return homography;
}

cv::Mat RobustMatcher::patch(const cv::Mat& image,
		const std::vector<cv::KeyPoint>& keypointArray) {
	cv::Mat points((int) keypointArray.size(), 1, CV_32SC2);
	for (size_t i = 0; i < keypointArray.size(); ++i) {
		int* ptr = points.ptr<int>((int) i);
		ptr[0] = (int) keypointArray[i].pt.x;
		ptr[1] = (int) keypointArray[i].pt.y;
	}
	cv::Rect bbox = cv::boundingRect(points);
	return image(bbox).clone();
}

// Clear matches for which NN ratio is > than threshold
// return the number of removed points
// (corresponding entries being cleared,
// i.e. size will be 0)
int RobustMatcher::ratioTest(std::vector<std::vector<cv::DMatch> > &matches) {
	int removed = 0;
	// for all matches
	for (std::vector<std::vector<cv::DMatch> >::iterator matchIterator =
			matches.begin(); matchIterator != matches.end(); ++matchIterator) {
		// if 2 NN has been identified
		if (matchIterator->size() > 1) {
			// check distance ratio
			if ((*matchIterator)[0].distance / (*matchIterator)[1].distance
					> ratio) {
				matchIterator->clear(); // remove match
				removed++;
			}
		} else { // does not have 2 neighbours
			matchIterator->clear(); // remove match
			removed++;
		}
	}
	return removed;
}
// Insert symmetrical matches in symMatches vector
void RobustMatcher::symmetryTest(
		const std::vector<std::vector<cv::DMatch> >& matches1,
		const std::vector<std::vector<cv::DMatch> >& matches2,
		std::vector<cv::DMatch>& symMatches) {
	// for all matches image 1 -> image 2
	for (std::vector<std::vector<cv::DMatch> >::const_iterator matchIterator1 =
			matches1.begin(); matchIterator1 != matches1.end();
			++matchIterator1) {
		// ignore deleted matches
		if (matchIterator1->size() < 2)
			continue;
		// for all matches image 2 -> image 1
		for (std::vector<std::vector<cv::DMatch> >::const_iterator matchIterator2 =
				matches2.begin(); matchIterator2 != matches2.end();
				++matchIterator2) {
			// ignore deleted matches
			if (matchIterator2->size() < 2)
				continue;
			// Match symmetry test
			if ((*matchIterator1)[0].queryIdx == (*matchIterator2)[0].trainIdx
					&& (*matchIterator2)[0].queryIdx
							== (*matchIterator1)[0].trainIdx) {
				// add symmetrical match
				symMatches.push_back(
						cv::DMatch((*matchIterator1)[0].queryIdx,
								(*matchIterator1)[0].trainIdx,
								(*matchIterator1)[0].distance));
				break; // next match in image 1 -> image 2
			}
		}
	}
}

// Identify good matches using RANSAC
// Return homography matrix
cv::Mat RobustMatcher::ransacTest(const std::vector<cv::DMatch>& matches,
		const std::vector<cv::KeyPoint>& keypoints1,
		const std::vector<cv::KeyPoint>& keypoints2,
		std::vector<cv::DMatch>& outMatches) {
	// Convert keypoints into Point2f
	std::vector<cv::Point2f> points1, points2;
	for (std::vector<cv::DMatch>::const_iterator it = matches.begin();
			it != matches.end(); ++it) {
		// Get the position of left keypoints
		float x = keypoints1[it->queryIdx].pt.x;
		float y = keypoints1[it->queryIdx].pt.y;
		points1.push_back(cv::Point2f(x, y));
		// Get the position of right keypoints
		x = keypoints2[it->trainIdx].pt.x;
		y = keypoints2[it->trainIdx].pt.y;
		points2.push_back(cv::Point2f(x, y));
	}
	std::vector<uchar> inliers(points1.size(), 0);
	cv::Mat homography = cv::findHomography(cv::Mat(points1), cv::Mat(points2),
			inliers, CV_RANSAC, distance);
	// extract the surviving (inliers) matches
	std::vector<uchar>::const_iterator itIn = inliers.begin();
	std::vector<cv::DMatch>::const_iterator itM = matches.begin();
	// for all matches
	for (; itIn != inliers.end(); ++itIn, ++itM) {
		if (*itIn) { // it is a valid match
			outMatches.push_back(*itM);
		}
	}
	return homography;
}

// Set the feature detector
void RobustMatcher::setFeatureDetector(cv::Ptr<cv::FeatureDetector>& detect) {
	detector = detect;
}
// Set the descriptor extractor
void RobustMatcher::setDescriptorExtractor(
		cv::Ptr<cv::DescriptorExtractor>& desc) {
	extractor = desc;
}
