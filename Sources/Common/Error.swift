// Copyright 2024 Anass Bouassaba.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

public struct VOErrorResponse: Decodable, Error {
    public let code: String
    public let status: Int
    public let message: String
    public let userMessage: String
    public let moreInfo: String

    public enum VOErrorCode: String, Codable {
        case group_not_found
        case file_not_found
        case invalid_path
        case workspace_not_found
        case organization_not_found
        case task_not_found
        case snapshot_not_found
        case s3_object_not_found
        case user_not_found
        case insights_not_found
        case mosaic_not_found
        case invitation_not_found
        case snapshot_cannot_be_patched
        case snapshot_has_pending_task
        case task_is_running
        case task_belongs_to_another_user
        case internal_server_error
        case missing_organization_permission
        case cannot_remove_last_owner_of_organization
        case cannot_remove_last_owner_of_group
        case missing_group_permission
        case missing_workspace_permission
        case missing_file_permission
        case s3_error
        case missing_query_param
        case invalid_path_param
        case invalid_query_param
        case storage_limit_exceeded
        case insufficient_storage_capacity
        case request_validation_error
        case file_already_child_of_destination
        case file_cannot_be_moved_into_itself
        case file_is_not_a_folder
        case file_is_not_a_file
        case target_is_grant_child_of_source
        case cannot_delete_workspace_root
        case file_cannot_be_coped_into_own_subtree
        case file_cannot_be_copied_into_itself
        case file_with_similar_name_exists
        case invalid_page_parameter
        case invalid_size_parameter
        case cannot_accept_non_pending_invitation
        case cannot_decline_non_pending_invitation
        case cannot_resend_non_pending_invitation
        case user_not_allowed_to_accept_invitation
        case user_not_allowed_to_decline_invitation
        case user_not_allowed_to_delete_invitation
        case user_already_member_of_organization
        case invalid_api_key
        case path_variables_and_body_parameters_not_consistent
    }
}
